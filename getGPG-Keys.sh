#!/usr/bin/env bash
set -Eeuo pipefail

CURL_OPTS=(--fail --location --silent --show-error --retry 3)

REDHAT_KEY_URL="https://www.redhat.com/security/data/fd431d51.txt"
EPEL_BASE="https://dl.fedoraproject.org/pub/epel"
RPMFUSION_FREE="https://download1.rpmfusion.org/free/el"
RPMFUSION_NONFREE="https://download1.rpmfusion.org/nonfree/el"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RESET='\033[0m'

log()  { printf "${GREEN}[INFO]${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}[WARN]${RESET} %s\n" "$*"; }
err()  { printf "${RED}[FAIL]${RESET} %s\n" "$*" >&2; }

download_key() {
    local url="$1"
    local destination="$2"
    local tmp="${destination}.tmp"

    if curl "${CURL_OPTS[@]}" "$url" -o "$tmp"; then
        if grep -qE \
            'BEGIN PGP PUBLIC KEY BLOCK|BEGIN PGP SIGNED MESSAGE' "$tmp"; then
            mv "$tmp" "$destination"
            log "Downloaded: $destination"
        else
            rm -f "$tmp"
            err "Invalid GPG key file: $url"
            return 1
        fi
    else
        rm -f "$tmp"
        err "Download failed: $url"
        return 1
    fi
}

for release in 8 9 10; do
    OUT_DIR="/srv/repos/rhel${release}/gpg-keys"
    mkdir -p "$OUT_DIR"

    log "Processing RHEL $release"

    # Red Hat release key bundle
    if [[ -s /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release ]]; then
        cp /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release \
            "$OUT_DIR/RPM-GPG-KEY-redhat-release"
        log "Copied installed Red Hat key bundle"
    else
        download_key "$REDHAT_KEY_URL" \
            "$OUT_DIR/RPM-GPG-KEY-redhat-release" ||
            warn "Verify Red Hat keys against the official key page"
    fi

    # Fedora EPEL
    download_key \
        "$EPEL_BASE/RPM-GPG-KEY-EPEL-${release}" \
        "$OUT_DIR/RPM-GPG-KEY-EPEL-${release}" ||
        warn "EPEL $release key download failed"

    # RPM Fusion Free
    download_key \
        "$RPMFUSION_FREE/RPM-GPG-KEY-rpmfusion-free-el-${release}" \
        "$OUT_DIR/RPM-GPG-KEY-rpmfusion-free-el-${release}" ||
        warn "RPM Fusion Free $release key download failed"

    # RPM Fusion Nonfree
    download_key \
        "$RPMFUSION_NONFREE/RPM-GPG-KEY-rpmfusion-nonfree-el-${release}" \
        "$OUT_DIR/RPM-GPG-KEY-rpmfusion-nonfree-el-${release}" ||
        warn "RPM Fusion Nonfree $release key download failed"

    log "Completed RHEL $release: $OUT_DIR"
done

printf '\n'
log "GPG key download process complete."

for release in 8 9 10; do
    printf '\nRHEL %s:\n' "$release"
    find "/srv/repos/rhel${release}/gpg-keys" \
        -maxdepth 1 -type f -name 'RPM-GPG-KEY*' -print | sort
done
