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
