#!/bin/bash

set -euo pipefail

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

ICON_THEME="Reversal-black"
REPO_URL="https://github.com/yeyushengfan258/Reversal-icon-theme.git"

info "Setting system to dark mode"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
success "Dark mode enabled"

if [ -d "$HOME/.local/share/icons/$ICON_THEME" ]; then
    info "Icon theme '$ICON_THEME' already installed"
else
    info "Installing Reversal icon theme (black)"
    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT
    
    git clone --depth 1 "$REPO_URL" "$temp_dir/Reversal-icon-theme" || {
        error "Failed to clone repository"
        exit 1
    }
    
    cd "$temp_dir/Reversal-icon-theme"
    ./install.sh -t black || {
        error "Failed to install icon theme"
        exit 1
    }
    success "Icon theme installed"
fi

info "Setting icon theme to: $ICON_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
success "Done"
