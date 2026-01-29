#!/usr/bin/env bash

# Enable xtrace if the DEBUG environment variable is set
if [[ ${DEBUG-} =~ ^1|yes|true$ ]]; then
    set -o xtrace
fi

set -o errexit          # Exit on most errors (see the manual)
set -o errtrace         # Ensure the error trap handler is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

info()    { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m[SUCCESS]\033[0m %s\n' "$*"; }
error()   { printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2; }

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
        stow --adopt "${package%/}" || {
            error "Failed to stow ${package%/}"
            exit 1
        }
    fi
done

# Restore repo versions (override any adopted files)
git checkout .

success "Done"
