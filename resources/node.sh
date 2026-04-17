#!/usr/bin/env bash
# NVM environment loader for Supergateway
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
exec "$@"
