#!/bin/bash

set -euo pipefail

info()    { echo -e "\033[1;34m[INFO]\033[0m $*"; }
success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
error()   { echo -e "\033[1;31m[ERROR]\033[0m $*" >&2; }
warning() { echo -e "\033[1;33m[WARNING]\033[0m $*"; }

if ! docker info &> /dev/null; then
    error "Docker not running"
    exit 1
fi

info "Stopping containers"
if [ "$(docker ps -q)" ]; then
    docker stop $(docker ps -q)
fi

info "Removing containers"
if [ "$(docker ps -aq)" ]; then
    docker rm $(docker ps -aq)
fi

info "Removing images"
if [ "$(docker images -q)" ]; then
    docker rmi $(docker images -q)
fi

info "Removing volumes"
if [ "$(docker volume ls -q)" ]; then
    docker volume rm $(docker volume ls -q)
fi

info "Removing networks"
docker network prune -f

info "Removing build cache"
docker builder prune -af

info "System prune"
docker system prune -af --volumes

success "Done"
