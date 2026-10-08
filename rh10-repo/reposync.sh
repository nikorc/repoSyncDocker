#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="${REPO_ROOT:-/repos}"
ARCH="$(uname -m)"

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

[[ $EUID -eq 0 ]] || die "Run as root."
mkdir -p "$REPO_ROOT"

# Enable CodeReady on an entitled RHEL 10 system.
if command -v subscription-manager >/dev/null 2>&1; then
    CODEREADY="codeready-builder-for-rhel-10-${ARCH}-rpms"

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

# Explicitly synchronize enabled repository IDs.
# Review this list with: dnf repolist --enabled
REPOS=(
    "rhel-10-for-${ARCH}-baseos-rpms" \
    "rhel-10-for-${ARCH}-appstream-rpms" \
    "codeready-builder-for-rhel-10-${ARCH}-rpms"
    "epel"
    "rpmfusion-free-updates"
    "rpmfusion-nonfree-updates"
)

# Use actual repository IDs present on this system.
for REPO in "${REPOS[@]}"; do
    if ! dnf repolist --enabled -q | grep -Fq "$REPO"; then
        subscription-manager repos --enable="$REPO"
        continue
    fi

    DEST="${REPO_ROOT}/${REPO}"
    mkdir -p "$DEST"

    info "Syncing $REPO"

    dnf reposync \
        --repoid="$REPO" \
        --download-path="$DEST" \
        --download-metadata \
        --newest-only \
        --arch="$ARCH,noarch" \
        || die "Synchronization failed: $REPO"

    ok "Completed $REPO"
done

ok "Repository synchronization finished."
info "Output directory: $REPO_ROOT"