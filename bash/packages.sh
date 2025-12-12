#!/bin/bash

set -euo pipefail

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

info "Updating system"
sudo dnf update -y && sudo dnf upgrade -y

info "Installing base packages"
sudo dnf install -y neovim git stow htop tree jq curl wget

info "Installing programming languages"
sudo dnf install -y python3 python3-pip

info "Installing VSCode"
if ! command -v code &> /dev/null; then
    if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    fi
    sudo dnf install -y code
else
    info "VSCode already installed"
fi

info "Installing Docker"
if ! command -v docker &> /dev/null; then
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine 2>/dev/null || true
    sudo dnf install -y dnf-plugins-core
    if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    fi
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo docker version --client
else
    info "Docker already installed"
fi

info "Installing kubectl"
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client
    rm kubectl
else
    info "kubectl already installed"
fi

success "Done"