#!/bin/bash
set -euxo pipefail
# Set variables first
REPO_NAME='serena-mcp'
BASE_IMAGE=$(cat ./build_data/base-image 2>/dev/null || echo "python:3.14-slim")
HAPROXY_IMAGE=$(cat ./build_data/haproxy-image 2>/dev/null || echo "haproxy:lts")
SERENA_VERSION=$(cat ./build_data/version 2>/dev/null || exit 1)
NVM_VERSION=$(cat ./build_data/nvm_version 2>/dev/null || curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oP '"tag_name":\s*"v\K[^"]+' || echo "0.40.4")
SERENA_PKG="serena-agent==${SERENA_VERSION}"
# mcp-proxy: stdio<->StreamableHTTP/SSE bridge. Replaces supergateway.
# Stateful by default (one stdio child per Mcp-Session-Id, reused across
# requests) — avoids the spawn-per-request memory leak that affected
# supergateway in stateless mode (supercorp-ai/supergateway#108).
MCP_PROXY_PKG=$(cat ./build_data/mcp_proxy_version 2>/dev/null || echo "mcp-proxy")
DOCKERFILE_NAME="Dockerfile.$REPO_NAME"

# Create a temporary file safely
TEMP_FILE=$(mktemp "${DOCKERFILE_NAME}.XXXXXX") || {
    echo "Error creating temporary file" >&2
    exit 1
}

# Check if this is a publication build
if [ -e ./build_data/publication ]; then
    # For publication builds, create a minimal Dockerfile that just tags the existing image
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        echo "ARG SERENA_VERSION=$SERENA_VERSION"
        echo "FROM $BASE_IMAGE"
    } > "$TEMP_FILE"
else
    # Write the Dockerfile content to the temporary file first
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        echo "ARG SERENA_VERSION=$SERENA_VERSION"
        cat << EOF
FROM $HAPROXY_IMAGE AS haproxy-src
FROM $BASE_IMAGE AS build

# Author info:
LABEL org.opencontainers.image.authors="MOHAMMAD MEKAYEL ANIK <mekayel.anik@gmail.com>"
LABEL org.opencontainers.image.description="Serena MCP Server — LSP-backed semantic code intelligence with mcp-proxy (stdio<->StreamableHTTP/SSE bridge)"
LABEL org.opencontainers.image.source="https://github.com/MekayelAnik/serena-mcp-docker"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"

ENV DEBIAN_FRONTEND=noninteractive

# Copy the entrypoint script into the container and make it executable
COPY ./resources/ /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/banner.sh /usr/local/bin/node.sh \\
    && if [ -f /usr/local/bin/build-timestamp.txt ]; then chmod +r /usr/local/bin/build-timestamp.txt; fi \\
    && mkdir -p /etc/haproxy \\
    && mv -vf /usr/local/bin/haproxy.cfg.template /etc/haproxy/haproxy.cfg.template \\
    && ls -la /etc/haproxy/haproxy.cfg.template

# Install required packages (Debian slim base — NOT alpine; pywebview/pystray are sdist-only)
RUN apt-get update && apt-get install -y --no-install-recommends \\
    bash curl wget gosu iproute2 netcat-openbsd libatomic1 dos2unix openssl \\
    build-essential git ssh ca-certificates haproxy \\
    && rm -rf /var/lib/apt/lists/*

# HAProxy with native QUIC/H3 support from official image
COPY --from=haproxy-src /usr/local/sbin/haproxy /usr/sbin/haproxy
RUN mkdir -p /usr/local/sbin && ln -sf /usr/sbin/haproxy /usr/local/sbin/haproxy \\
    && ln -sf /usr/sbin/gosu /usr/local/bin/su-exec 2>/dev/null || true

# Node.js via NVM. The mcp-proxy bridge is pure Python and does NOT need
# Node, but several of Serena's bundled language servers do:
#   - pyright (Python LSP): wraps a Node-based langserver.js
#   - typescript-language-server, vue-language-server, etc.
# Without Node on PATH, pyright tries to auto-install Node via nodeenv
# into ~/.cache/pyright-python at first use, which usually fails inside
# a sandboxed container (network / perms). Pre-install once at build.
# Installed under /opt/nvm so the non-root 'serena' runtime user can
# traverse into it. /root stays 0700 (default Debian behavior).
ENV NVM_VERSION=${NVM_VERSION}
ENV NVM_DIR=/opt/nvm
RUN mkdir -p /opt/nvm && chmod 755 /opt /opt/nvm \\
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v\${NVM_VERSION}/install.sh | bash \\
    && . "\$NVM_DIR/nvm.sh" \\
    && nvm install node \\
    && nvm alias default node \\
    && ln -sf "\$(which node)" /usr/local/bin/node \\
    && ln -sf "\$(which npm)" /usr/local/bin/npm \\
    && ln -sf "\$(which npx)" /usr/local/bin/npx \\
    && node --version && npm --version

# Install Serena + mcp-proxy from PyPI in one layer (shared pip cache).
RUN --mount=type=cache,target=/root/.cache/pip \\
    echo "Installing packages: ${SERENA_PKG} + ${MCP_PROXY_PKG}" && \\
    pip install --no-cache-dir --break-system-packages ${SERENA_PKG} ${MCP_PROXY_PKG} && \\
    echo "Packages installed successfully" && \\
    mcp-proxy --version || true

# Seed default Serena config (non-interactive dashboard)
ENV SERENA_HOME=/config/serena
RUN mkdir -p \${SERENA_HOME} \\
    && serena generate-config --output \${SERENA_HOME}/serena_config.yml 2>/dev/null || true \\
    && if [ -f \${SERENA_HOME}/serena_config.yml ]; then \\
         sed -i 's/^gui_log_window: .*/gui_log_window: False/' \${SERENA_HOME}/serena_config.yml; \\
         sed -i 's/^web_dashboard_listen_address: .*/web_dashboard_listen_address: 0.0.0.0/' \${SERENA_HOME}/serena_config.yml; \\
         sed -i 's/^web_dashboard_open_on_launch: .*/web_dashboard_open_on_launch: False/' \${SERENA_HOME}/serena_config.yml; \\
       fi

# Use an ARG for the default port
ARG PORT=9121

# Add ARG for API key
ARG API_KEY=""

# Set an ENV variable from the ARG for runtime
ENV PORT=\${PORT}
ENV API_KEY=\${API_KEY}

# L7 health check: auto-detects HTTP/HTTPS via ENABLE_HTTPS env var.
# /healthz is answered by HAProxy locally (mcp-proxy lacks a configurable
# health endpoint) so the check itself returns in well under a second.
# start-period=60s tolerates the cold-start LSP boot (pyright workspace
# analysis can take 5-30s on real projects) so orchestrators do not flap
# the container before the backend is ready.
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \\
    CMD sh -c 'wget -q --spider --no-check-certificate \$([ "\$ENABLE_HTTPS" = "true" ] && echo https || echo http)://127.0.0.1:\${PORT:-9121}/healthz'

VOLUME ["/data", "/config"]

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EOF
    } > "$TEMP_FILE"
fi

# Atomically replace the target file with the temporary file
if mv -f "$TEMP_FILE" "$DOCKERFILE_NAME"; then
    echo "Dockerfile for $REPO_NAME created successfully."
else
    echo "Error: Failed to create Dockerfile for $REPO_NAME" >&2
    rm -f "$TEMP_FILE"
    exit 1
fi
