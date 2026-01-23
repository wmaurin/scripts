#!/bin/bash

set -euo pipefail

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="git@github.com:wmaurin/dotfiles.git"

if ! command -v stow &> /dev/null; then
    info "Installing stow"
    sudo dnf install -y stow
else
    info "stow already installed"
fi

if [ -d "$DOTFILES_DIR" ]; then
    info "Updating repository"
    cd "$DOTFILES_DIR"
    git pull || {
        error "Failed to update"
        exit 1
    }
else
    info "Cloning repository"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || {
        error "Failed to clone"
        exit 1
    }
fi

info "Configuring dotfiles"
cd "$DOTFILES_DIR"
for package in */; do
    if [ -d "$package" ]; then
        stow "${package%/}" || {
            error "Failed to stow ${package%/}"
            exit 1
        }
    fi
done

success "Done"
