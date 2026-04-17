<p align="center"><img src="https://raw.githubusercontent.com/oraios/serena/refs/heads/main/resources/serena-logo.svg" alt="Serena Logo" width="200"></p>

# Serena MCP Server

<p align="center">
  <a href="https://hub.docker.com/r/mekayelanik/serena-mcp"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/mekayelanik/serena-mcp?style=flat-square&logo=docker"></a>
  <a href="https://hub.docker.com/r/mekayelanik/serena-mcp"><img alt="Docker Stars" src="https://img.shields.io/docker/stars/mekayelanik/serena-mcp?style=flat-square&logo=docker"></a>
  <a href="https://github.com/MekayelAnik/serena-mcp-docker/pkgs/container/serena-mcp"><img alt="GHCR" src="https://img.shields.io/badge/GHCR-ghcr.io%2Fmekayelanik%2Fserena--mcp-blue?style=flat-square&logo=github"></a>
  <a href="https://github.com/MekayelAnik/serena-mcp-docker/blob/main/LICENSE"><img alt="License: GPL-3.0" src="https://img.shields.io/badge/License-GPL--3.0-blue?style=flat-square"></a>
  <a href="https://hub.docker.com/r/mekayelanik/serena-mcp"><img alt="Platforms" src="https://img.shields.io/badge/Platforms-amd64%20%7C%20arm64-lightgrey?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/serena-mcp-docker/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/MekayelAnik/serena-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/serena-mcp-docker/forks"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/MekayelAnik/serena-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/serena-mcp-docker/issues"><img alt="GitHub Issues" src="https://img.shields.io/github/issues/MekayelAnik/serena-mcp-docker?style=flat-square"></a>
</p>

## Unofficial Multi-Architecture Docker Image for LSP-Backed Semantic Code Intelligence

> **Note:** This is an **unofficial** community-maintained Docker image. It is not affiliated with or endorsed by [Oraios GmbH](https://github.com/oraios/serena), the creators of Serena.

## Table of Contents

- [Overview](#overview)
- [Supported Architectures](#supported-architectures)
- [Available Tags](#available-tags)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Context Selection](#context-selection)
- [MCP Client Configuration](#mcp-client-configuration)
- [Transport Selection](#transport-selection)
- [Single-Project vs Multi-Project Deploys](#single-project-vs-multi-project-deploys)
- [Network Configuration](#network-configuration)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Additional Resources](#additional-resources)
- [Support & License](#support--license)

---

<p align="center">
  <a href="https://www.buymeacoffee.com/mekayelanik" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="195">
  </a>
</p>

---

## Overview

Serena is an LSP-backed MCP providing 30+ tools for semantic code intelligence across 30+ languages (Python, TypeScript, Rust, Go, Java, C/C++, Ruby, PHP, Kotlin, and more). Fills gaps where tree-sitter-based code-graph tools (like CodeGraphContext, GitNexus, Narsil) stop: real symbol resolution via language servers, cross-file rename, symbol-aware edits.

This Docker image wraps [serena-agent](https://pypi.org/project/serena-agent/) with Supergateway for HTTP/SSE/WebSocket transport and HAProxy for TLS, rate limiting, API key auth, and CORS — matching the transport layer used by all other MCP images in this ecosystem.

### Key Features

- **Multi-Architecture Support** - Native support for x86-64 and ARM64
- **LSP-Backed Intelligence** - Real symbol resolution via pyright, gopls, rust-analyzer, and more
- **Multiple Transport Protocols** - SHTTP, SSE, WebSocket, and pure stdio support
- **Secure by Design** - HAProxy with TLS, API key auth, rate limiting, IP allowlist/blocklist, CORS
- **Context-Aware** - Adapts tool exposure per MCP client (Claude Code, Cursor, VS Code, ChatGPT, etc.)
- **Production Ready** - Stable releases with comprehensive CI/CD and multi-registry publishing
- **Easy Configuration** - Simple environment variable setup

---

## Supported Architectures

| Architecture | Tag |
|:-------------|:----|
| x86-64 | `amd64` |
| ARM64 | `arm64` |

Multi-architecture images are available — Docker automatically selects the correct platform.

---

## Available Tags

| Tag | Description |
|:----|:------------|
| `stable` | Production-ready, tested release |
| `latest` | Most recent release |
| `1.1.2` | Specific version |
| `beta` | Pre-release testing |

---

### System Requirements

| Resource | Minimum | Recommended |
|:---------|:--------|:------------|
| CPU | 1 core | 2+ cores |
| RAM | 512 MB | 1 GB+ |
| Disk | 500 MB | 1 GB+ |
| Docker | 23.0+ | Latest |
| Docker Compose | 2.0+ | Latest |

---

## Quick Start

### Docker Compose (Recommended)

```yaml
services:
  serena-mcp:
    image: mekayelanik/serena-mcp:latest
    container_name: serena-mcp
    restart: unless-stopped
    ports:
      - "9121:9121"
    volumes:
      - /path/to/your/project:/data:rw
      - serena-config:/config
      - serena-cache:/home/serena/.cache
    environment:
      - PORT=9121
      - INTERNAL_PORT=38011
      - PUID=1000
      - PGID=1000
      - TZ=UTC
      - PROTOCOL=SHTTP
      - SERENA_PROJECT=/data
      - SERENA_CONTEXT=desktop-app
      - SERENA_TRANSPORT=stdio
      - SERENA_LOG_LEVEL=INFO
      - ENABLE_HTTPS=false
      - HTTP_VERSION_MODE=auto
      # Optional: require Bearer token auth at HAProxy layer
      # - API_KEY=replace-with-strong-secret
      # Optional: CORS origins
      # - CORS=*

volumes:
  serena-config:
    driver: local
  serena-cache:
    driver: local
```

### Docker CLI

```bash
docker run --rm -i \
  -v /path/to/your/project:/data:rw \
  -e SERENA_PROJECT=/data \
  mekayelanik/serena-mcp:latest
```

### Access Endpoints

| Protocol | Endpoint | Description |
|:---------|:---------|:------------|
| SHTTP | `http://host-ip:9121/mcp` | Streamable HTTP (default) |
| SSE | `http://host-ip:9121/sse` | Server-Sent Events |
| WebSocket | `ws://host-ip:9121/message` | WebSocket |
| Health | `http://host-ip:9121/healthz` | Health check endpoint |

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PORT` | `9121` | External server port |
| `INTERNAL_PORT` | `38011` | Internal MCP server port used by supergateway |
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `UTC` | Container timezone ([TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)) |
| `PROTOCOL` | `SHTTP` | Transport protocol (`SHTTP`, `SSE`, `WS`, `STDIO`) |
| `SERENA_PROJECT` | `/data` | Project path (mapped to `--project`) |
| `SERENA_CONTEXT` | `desktop-app` | Client context (see [Context Selection](#context-selection)) |
| `SERENA_TRANSPORT` | `stdio` | Serena transport (`stdio`, `sse`, `streamable-http`) |
| `SERENA_PORT` | `9121` | Serena port when transport != stdio |
| `SERENA_MODES` | *(empty)* | Comma-separated modes fed to `--mode` |
| `SERENA_LOG_LEVEL` | `INFO` | Log level (`DEBUG`, `INFO`, `WARNING`, `ERROR`) |
| `API_KEY` | *(empty)* | Enables Bearer token auth (`Authorization: Bearer <API_KEY>`) |
| `CORS` | *(empty)* | Comma-separated CORS origins, supports `*` |
| `ENABLE_HTTPS` | `false` | Enables TLS termination in HAProxy |
| `TLS_CERT_PATH` | `/etc/haproxy/certs/server.crt` | TLS cert path |
| `TLS_KEY_PATH` | `/etc/haproxy/certs/server.key` | TLS private key path |
| `TLS_PEM_PATH` | `/etc/haproxy/certs/server.pem` | Combined PEM file used by HAProxy |
| `TLS_CN` | `localhost` | CN for auto-generated certificate |
| `TLS_SAN` | `DNS:<TLS_CN>` | SAN for auto-generated certificate |
| `TLS_DAYS` | `365` | Auto-generated cert validity period |
| `TLS_MIN_VERSION` | `TLSv1.3` | Minimum TLS protocol (`TLSv1.2` or `TLSv1.3`) |
| `HTTP_VERSION_MODE` | `auto` | `auto`, `all`, `h1`, `h2`, `h3`, `h1+h2` |
| `RATE_LIMIT` | `0` | Max requests per `RATE_LIMIT_PERIOD` per IP (`0` = disabled) |
| `RATE_LIMIT_PERIOD` | `10s` | Sliding window for rate limiting (e.g., `10s`, `1m`, `1h`) |
| `MAX_CONNECTIONS_PER_IP` | `0` | Max concurrent connections per IP (`0` = disabled) |
| `IP_ALLOWLIST` | *(empty)* | Comma-separated IPs/CIDRs to allow (all others blocked) |
| `IP_BLOCKLIST` | *(empty)* | Comma-separated IPs/CIDRs to block |

### HTTPS and HTTP Version Notes

- When `ENABLE_HTTPS=false`, only HTTP/1.1 is available regardless of `HTTP_VERSION_MODE`
- When `ENABLE_HTTPS=true`, the server auto-generates a self-signed certificate if none is provided
- HTTP/3 (QUIC) requires `ENABLE_HTTPS=true` and a HAProxy build with QUIC support
- Valid `HTTP_VERSION_MODE` values: `auto` (h1+h2+h3 if available), `h1`, `h2`, `h3`, `h1+h2`, `all`

### API Key Authentication Notes

- API key auth protects access but does **not** encrypt traffic — use with `ENABLE_HTTPS=true` for security
- Health endpoint (`/healthz`) always bypasses authentication
- Key length must be 5-256 characters

### Rate Limiting and IP Access Control

- `RATE_LIMIT` and `RATE_LIMIT_PERIOD` work together (e.g., `RATE_LIMIT=100` + `RATE_LIMIT_PERIOD=1m` = 100 req/min)
- `MAX_CONNECTIONS_PER_IP` limits concurrent connections (useful for preventing abuse)
- `IP_ALLOWLIST` and `IP_BLOCKLIST` accept comma-separated IPs or CIDR ranges
- When both are set, blocklist is checked first, then allowlist

### User & Group IDs

Set `PUID` and `PGID` to match your host user to avoid permission issues with mounted volumes:

```bash
-e PUID=$(id -u) -e PGID=$(id -g)
```

### Timezone Examples

```bash
-e TZ=America/New_York
-e TZ=Europe/London
-e TZ=Asia/Dhaka
```

---

## Context Selection

The `SERENA_CONTEXT` environment variable controls which tools Serena exposes, tailored per MCP client:

| Client | `SERENA_CONTEXT` | What it does |
|:-------|:-----------------|:-------------|
| Claude Code CLI | `claude-code` | Excludes tools Claude Code already has (create/read file, shell) — tighter token budget |
| Cursor / Windsurf | `ide` | Generic IDE; excludes `create_text_file` |
| VS Code + Copilot | `vscode` | Assumes internal file/shell tools; activate_project required |
| ChatGPT Desktop | `chatgpt` | 30-tool cap + short descriptions |
| Codex | `codex` | Excludes shell + non-symbolic edits |
| GitHub Copilot CLI | `copilot-cli` | Tuned for `gh copilot` |
| JetBrains AI Assistant | `jb-ai-assistant` | JetBrains-specific tool set |
| JetBrains Copilot plugin | `jb-copilot-plugin` | JetBrains Copilot variant |
| Junie | `junie` | JetBrains Junie context |
| OpenAI-compat agent | `oaicompat-agent` | Generic OpenAI-compatible agent |
| Google Antigravity | `antigravity` | Google Antigravity context |
| Any desktop / chat app | `desktop-app` (**default**) | Full toolset — broadest compatibility |

---

## MCP Client Configuration

### Transport Support

| Transport | Protocol | Use Case |
|:----------|:---------|:---------|
| `SHTTP` | Streamable HTTP | Best for remote/multi-client setups (default) |
| `SSE` | Server-Sent Events | Compatible with older MCP clients |
| `WS` | WebSocket | Real-time bidirectional communication |
| `STDIO` | Standard I/O | Single local client, lightest mode |

### Claude Code

Configure in `~/.config/claude-code/mcp.json` or project-level `.mcp.json`:

```json
{
  "mcpServers": {
    "serena": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-v", "${PWD}:/data:rw",
        "-e", "SERENA_PROJECT=/data",
        "-e", "SERENA_CONTEXT=claude-code",
        "-e", "PROTOCOL=STDIO",
        "mekayelanik/serena-mcp:latest"
      ]
    }
  }
}
```

### VS Code (Cline/Roo-Cline)

```json
{
  "mcpServers": {
    "serena": {
      "transport": "http",
      "url": "http://host-ip:9121/mcp"
    }
  }
}
```

### Claude Desktop App

```json
{
  "mcpServers": {
    "serena": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-v", "/path/to/project:/data:rw",
        "-e", "SERENA_PROJECT=/data",
        "-e", "PROTOCOL=STDIO",
        "mekayelanik/serena-mcp:latest"
      ]
    }
  }
}
```

### Codex CLI

Configure in `~/.codex/config.json`:

```json
{
  "mcpServers": {
    "serena": {
      "transport": "http",
      "url": "http://host-ip:9121/mcp"
    }
  }
}
```

### Codeium (Windsurf)

```json
{
  "mcpServers": {
    "serena": {
      "transport": "http",
      "url": "http://host-ip:9121/mcp"
    }
  }
}
```

### Cursor

```json
{
  "mcpServers": {
    "serena": {
      "transport": "http",
      "url": "http://host-ip:9121/mcp"
    }
  }
}
```

### Testing Configuration

Test the SHTTP endpoint:
```bash
curl -s http://localhost:9121/healthz
```

---

## Transport Selection

| Transport | `SERENA_TRANSPORT` | `PROTOCOL` | Port exposed | Use when |
|:----------|:-------------------|:-----------|:-------------|:---------|
| Pure stdio (lightest) | `stdio` | `STDIO` | none | Single local client; `docker run -i` only |
| SSE / streamable-HTTP via HAProxy | `stdio` | `SHTTP` (default) | `$PORT` (9121) | Multiple remote clients, need TLS/QUIC |
| Direct SSE (no HAProxy) | `sse` | *(any)* | `$SERENA_PORT` (9121) | Dev / debug, single client |
| Streamable HTTP (MCP spec) | `streamable-http` | *(any)* | `$SERENA_PORT` | MCP spec-compliant HTTP client |

### Common Env Overrides

```bash
# Minimal (most common)
-e SERENA_PROJECT=/data

# Tight for Claude Code
-e SERENA_PROJECT=/data -e SERENA_CONTEXT=claude-code

# SSE mode exposed
-e SERENA_TRANSPORT=sse -e SERENA_PORT=9121 -p 9121:9121

# Enable dashboard (bind 127.0.0.1 inside; publish only if you want remote access)
-p 127.0.0.1:24282:24282

# With API key auth at HAProxy layer
-e API_KEY=your-strong-secret -p 9121:9121

# Non-root UID matching host
-e PUID=$(id -u) -e PGID=$(id -g)
```

---

## Single-Project vs Multi-Project Deploys

### Pattern 1 — One container per project (recommended)

```yaml
services:
  serena-hfe:
    image: mekayelanik/serena-mcp:latest
    environment: [SERENA_PROJECT=/data]
    volumes: [/host/hfe:/data:rw]
  serena-loinc:
    image: mekayelanik/serena-mcp:latest
    environment: [SERENA_PROJECT=/data]
    volumes: [/host/loinc:/data:rw]
```

Pros: crash isolation, per-project resource limits, matches other MCP containers.

### Pattern 2 — One container, many projects, switch at runtime

```yaml
services:
  serena:
    image: mekayelanik/serena-mcp:latest
    environment:
      - SERENA_PROJECT=/projects/hfe
    volumes:
      - /host/hfe:/projects/hfe:rw
      - /host/loinc:/projects/loinc:rw
      - serena-config:/config
volumes:
  serena-config:
```

Then in your MCP client, call Serena's `activate_project` tool with `/projects/loinc` to switch — no container restart. Shared LSP cache, fast switching, but crashes kill all project sessions.

---

## Network Configuration

### Comparison

| Mode | Use Case | Isolation | Complexity |
|:-----|:---------|:----------|:-----------|
| Bridge (default) | Most deployments | Container-level | Low |
| Host | Maximum performance | None | Medium |
| MACVLAN | Dedicated IP | Network-level | High |

### Bridge Network (Default)

```yaml
services:
  serena-mcp:
    ports:
      - "9121:9121"
```

### Host Network (Linux Only)

```yaml
services:
  serena-mcp:
    network_mode: host
    environment:
      - PORT=9121
```

### MACVLAN Network (Advanced)

```yaml
networks:
  mcp_net:
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
services:
  serena-mcp:
    networks:
      mcp_net:
        ipv4_address: 192.168.1.100
```

---

## Updating

### Docker Compose

```bash
docker compose pull
docker compose down && docker compose up -d
```

### Docker CLI

```bash
docker pull mekayelanik/serena-mcp:latest
docker stop serena-mcp && docker rm serena-mcp
# Re-run your docker run command
```

### One-Time Update with Watchtower

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --run-once serena-mcp
```

Check tag `stable` for production; `<version>` (e.g. `1.1.2`) for pinning.

---

## Troubleshooting

### Pre-Flight Checklist

1. Docker version 23.0+ installed
2. Sufficient disk space (500MB minimum)
3. Port not already in use
4. Project volume mounted correctly

### Common Issues

#### Container Won't Start

- Check logs: `docker logs serena-mcp`
- Verify image pulled: `docker images | grep serena-mcp`
- Check port conflicts: `ss -tlnp | grep 9121`

#### Permission Errors

- Set correct PUID/PGID: `-e PUID=$(id -u) -e PGID=$(id -g)`
- Verify volume permissions: `ls -la /path/to/your/project`

#### Client Cannot Connect

- Verify container is running: `docker ps | grep serena-mcp`
- Test health endpoint: `curl http://localhost:9121/healthz`
- Check firewall rules for port 9121
- If using HTTPS, ensure certificates are valid

#### `find_references` Returns No Results

- Ensure `SERENA_PROJECT` points at repo root
- Check logs for LSP startup errors
- First invocation may be slow while pyright indexes

#### LSP Startup Slow (>30s first call)

- Normal on first run; LSP cache persists in `/home/serena/.cache` volume
- Mount cache volume to speed up subsequent starts

#### `Context name 'ide-assistant' is deprecated` Warning

- Change `SERENA_CONTEXT` to `claude-code`

#### Dashboard Port 24282 Not Reachable

- Bound to `0.0.0.0` inside container but not published
- Add `-p 127.0.0.1:24282:24282` (keep dashboard local; never expose publicly)

#### Slow ARM Performance

- Serena uses QEMU emulation on ARM for some workloads
- Native ARM64 images are provided for best performance
- Consider allocating more memory: `--memory=2g`

### Debug Information

```bash
# Container logs
docker logs serena-mcp

# Enter container shell
docker exec -it serena-mcp bash

# Check serena version
docker exec serena-mcp serena --version

# Check running processes
docker exec serena-mcp ps aux
```

---

## Security

- Dashboard port `24282` — **never expose publicly**. Default compose does NOT publish it. If needed, bind to `127.0.0.1` on host.
- `API_KEY` env — optional HAProxy Bearer auth. Generate with `openssl rand -base64 32`. Rotate quarterly.
- Project volumes — mount `:ro` when Serena only needs read access; `:rw` is required for symbol-editing tools.
- No network egress required for stdio mode; SHTTP mode respects `ENABLE_HTTPS` + `API_KEY`.

---

## Additional Resources

### Documentation

- [Serena GitHub Repository](https://github.com/oraios/serena)
- [Serena on PyPI](https://pypi.org/project/serena-agent/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
- [Supergateway](https://github.com/nichochar/supergateway)

### Docker Resources

- [Docker Hub Repository](https://hub.docker.com/r/mekayelanik/serena-mcp)
- [GitHub Container Registry](https://github.com/MekayelAnik/serena-mcp-docker/pkgs/container/serena-mcp)

### Monitoring

- Health check: `GET /healthz`
- Container logs: `docker logs serena-mcp`

---

<p align="center">
  <a href="https://www.buymeacoffee.com/mekayelanik" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="195">
  </a>
</p>

---

## Support & License

### Getting Help

- [GitHub Issues](https://github.com/MekayelAnik/serena-mcp-docker/issues) — Bug reports and feature requests
- [Discussions](https://github.com/MekayelAnik/serena-mcp-docker/discussions) — Questions and community support

### Contributing

Pull requests are welcome! Please open an issue first to discuss proposed changes.

### License

This Docker image packaging is licensed under [GPL-3.0](LICENSE).

The upstream [serena-agent](https://github.com/oraios/serena) is licensed under the [MIT License](https://github.com/oraios/serena/blob/main/LICENSE) by Oraios GmbH.
