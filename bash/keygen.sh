#!/bin/bash

set -euo pipefail

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

if [ ! -f ~/.ssh/id_ed25519 ]; then
    info "Generating SSH key"
    ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
    cat ~/.ssh/id_ed25519.pub
    success "Done"
else
    info "SSH key exists"
fi
