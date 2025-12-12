#!/bin/bash

set -euo pipefail

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="git@github.com:wmaurin/dotfiles.git"
    
# Check if stow is installed
if ! command -v stow &> /dev/null; then
    info "GNU Stow not found. Installing via dnf"
    sudo dnf install -y stow
    success "GNU Stow installed"
fi
   
# Clone or update dotfiles repository
if [ -d "$DOTFILES_DIR" ]; then
    info "Dotfiles directory already exists at $DOTFILES_DIR; updating repository"
    cd "$DOTFILES_DIR"
    git pull || {
        error "Failed to update dotfiles repository"
        exit 1
    }
else
    info "Cloning dotfiles repository"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || {
        error "Failed to clone dotfiles repository"
        exit 1
    }
    success "Repository cloned to $DOTFILES_DIR"
fi
  
# Configure dotfiles using stow
info "Configuring dotfiles with GNU Stow"
cd "$DOTFILES_DIR"
for package in */; do
    if [ -d "$package" ]; then
        info "Stowing ${package%/}"
        stow "${package%/}" || {
            error "Failed to stow ${package%/}"
            exit 1
        }
    fi
done
    
success "Done"


