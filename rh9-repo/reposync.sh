#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="${REPO_ROOT:-/repos}"
ARCH="$(uname -m)"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

die() {
    error "$*"
    exit 1
}

# Require root
[[ "$EUID" -eq 0 ]] || die "Run this script as root."

mkdir -p "$REPO_ROOT"

# Enable CodeReady on an entitled RHEL 9 system.
if command -v subscription-manager >/dev/null 2>&1; then
    CODEREADY="codeready-builder-for-rhel-9-${ARCH}-rpms"

    if subscription-manager repos --enable="$CODEREADY"; then
        ok "Enabled $CODEREADY"
    else
        warn "Could not enable RHEL CodeReady; check entitlement."
    fi
else
    warn "subscription-manager unavailable; checking existing repositories."
fi

dnf clean metadata
dnf makecache --refresh || die "Repository metadata refresh failed."

# Refresh repository metadata
dnf clean metadata
dnf makecache --refresh \
    || die "Unable to refresh repository metadata."

# Synchronize all enabled repositories
mapfile -t REPOS < <(
    dnf repolist --enabled -q |
    awk 'NR > 1 && $1 !~ /^repo/ && $1 !~ /^Last/ {print $1}'
)

((${#REPOS[@]} > 0)) || die "No enabled repositories found."

info "Repositories selected for synchronization:"
printf '  %s\n' "${REPOS[@]}"

for REPO in "${REPOS[@]}"; do
    DEST="${REPO_ROOT}/${REPO}"

    info "Syncing ${REPO} -> ${DEST}"
    mkdir -p "$DEST"

    if dnf reposync \
        --repoid="$REPO" \
        --download-path="$DEST" \
        --download-metadata \
        --newest-only \
        --arch="${ARCH},noarch"; then
        ok "Completed ${REPO}"
    else
        error "Failed to sync ${REPO}"
        exit 1
    fi
done

ok "All repositories synchronized."
info "Repository root: ${REPO_ROOT}"
