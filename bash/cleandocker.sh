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
