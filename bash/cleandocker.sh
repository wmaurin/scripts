#!/bin/bash

set -euo pipefail

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }

if ! docker info &> /dev/null; then
    error "Docker not running"
    exit 1
fi

info "Stopping containers"
docker ps -q | xargs -r docker stop

info "Removing containers"
docker ps -aq | xargs -r docker rm

info "Removing images"
docker images -q | xargs -r docker rmi

info "Removing volumes"
docker volume ls -q | xargs -r docker volume rm

info "Removing networks"
docker network prune -f

info "Removing build cache"
docker builder prune -af

info "System prune"
docker system prune -af --volumes

success "Done"
