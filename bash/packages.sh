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

info "Updating system"
sudo dnf update -y && sudo dnf upgrade -y

info "Installing base packages"
sudo dnf install -y neovim git stow htop tree jq curl wget

info "Installing programming languages"
sudo dnf install -y python3 python3-pip

info "Installing Docker"
if ! command -v docker &> /dev/null; then
    sudo dnf remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine 2>/dev/null || true
    if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
        sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    fi
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    info "Added $USER to docker group (log out and back in to apply)"
    sudo docker version --client
else
    info "Docker already installed"
fi

info "Installing kubectl"
if ! command -v kubectl &> /dev/null && [ ! -x /usr/local/bin/kubectl ]; then
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check || {
        error "kubectl checksum verification failed"
        rm -f kubectl kubectl.sha256
        exit 1
    }
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl kubectl.sha256
    /usr/local/bin/kubectl version --client
else
    info "kubectl already installed"
fi

success "Done"
