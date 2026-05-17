#!/usr/bin/env bash
# NVM environment loader. Node.js is required by Serena's bundled
# language servers (pyright wraps a Node-based langserver.js, the
# TypeScript LSP is Node, etc.) — NOT by the stdio<->HTTP bridge,
# which is now mcp-proxy (pure Python).
export NVM_DIR="/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
exec "$@"
