#!/usr/bin/env bash
# NVM environment loader for Supergateway
export NVM_DIR="/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
exec "$@"
