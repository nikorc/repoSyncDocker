#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

MIRROR_ROOT="${MIRROR_ROOT:-/repos/rhel10}"
KEY_DIR="${MIRROR_ROOT}/gpg-keys"
ARCH="$(uname -m)"
RHEL_MAJOR=10

# Allow an alternate target architecture when intentionally configured.
case "${ARCH}" in
    x86_64|aarch64) ;;
    *)
        echo "Unsupported architecture: ${ARCH}" >&2
        exit 1
        ;;
esac

BASEOS="rhel-${RHEL_MAJOR}-for-${ARCH}-baseos-rpms"
APPSTREAM="rhel-${RHEL_MAJOR}-for-${ARCH}-appstream-rpms"
CODEREADY="codeready-builder-for-rhel-${RHEL_MAJOR}-${ARCH}-rpms"

mkdir -p "${KEY_DIR}" "${MIRROR_ROOT}"

log() {
    printf '\n[%s] %s\n' "$(date '+%F %T')" "$*"
}

require_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "Run this container as root." >&2
        exit 1
    fi
}

download_key() {
    local url="$1"
    local name="$2"
    local temp="${KEY_DIR}/.${name}.tmp"

    log "Downloading GPG key: ${name}"
    curl --fail --location --silent --show-error \
        --retry 3 --retry-delay 2 \
        "${url}" -o "${temp}"

    # Validate that the download is an ASCII-armored GPG key.
    if ! grep -qE \
        'BEGIN PGP PUBLIC KEY BLOCK|BEGIN PGP PUBLIC KEY BLOCK' \
        "${temp}"; then
        echo "Invalid GPG key download: ${url}" >&2
        rm -f "${temp}"
        return 1
    fi

    # Replace the existing key only after a successful download.
    mv -f "${temp}" "${KEY_DIR}/${name}"
}

enable_rhel_repos() {
    log "Checking Red Hat entitlement and enabling RHEL 10 repositories"

    command -v subscription-manager >/dev/null || {
        echo "subscription-manager is missing." >&2
        exit 1
    }

    subscription-manager repos \
        --enable="${BASEOS}" \
        --enable="${APPSTREAM}" \
        --enable="${CODEREADY}"

    dnf clean all
    dnf makecache --refresh
}

configure_third_party_repos() {
    log "Installing EPEL 10 release package"
    dnf -y install \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

    log "Installing RPM Fusion EL 10 release packages"
    dnf -y install \
        "https://download1.rpmfusion.org/free/el/rpmfusion-free-release-10.noarch.rpm" \
        "https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-10.noarch.rpm"

    dnf config-manager --set-enabled \
        "${BASEOS}" \
        "${APPSTREAM}" \
        "${CODEREADY}" \
        epel \
        rpmfusion-free \
        rpmfusion-nonfree

    dnf clean all
    dnf makecache --refresh
}

download_gpg_keys() {
    log "Saving repository signing keys"

    # Red Hat release signing key shipped with the UBI image.
    local redhat_key
    for redhat_key in /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release \
                      /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-beta; do
        if [[ -f "${redhat_key}" ]]; then
            install -m 0644 "${redhat_key}" "${KEY_DIR}/"
        fi
    done

    download_key \
        "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-10" \
        "RPM-GPG-KEY-EPEL-10"

    download_key \
        "https://download1.rpmfusion.org/free/el/RPM-GPG-KEY-rpmfusion-free-el-10" \
        "RPM-GPG-KEY-rpmfusion-free-el-10"

    download_key \
        "https://download1.rpmfusion.org/nonfree/el/RPM-GPG-KEY-rpmfusion-nonfree-el-10" \
        "RPM-GPG-KEY-rpmfusion-nonfree-el-10"

    # Save keys referenced by enabled repository definitions, too.
    local key
    while IFS= read -r key; do
        [[ -n "${key}" ]] || continue
        key="${key#file://}"
        if [[ -f "${key}" ]]; then
            install -m 0644 "${key}" "${KEY_DIR}/"
        fi
    done < <(
        awk -F= '
            /^[[:space:]]*gpgkey[[:space:]]*=/ {
                sub(/^[^=]*=/, "")
                n=split($0, a, /[[:space:]]+/)
                for (i=1; i<=n; i++)
                    if (a[i] ~ /^file:\/\//) print a[i]
            }
        ' /etc/yum.repos.d/*.repo 2>/dev/null || true
    )
}

sync_repo() {
    local repo_id="$1"
    local dest="$2"

    log "Syncing latest RPMs from ${repo_id}"

    mkdir -p "${dest}"

    # Download only the latest RPM versions.
    # Do not download upstream metadata that can reference
    # older RPMs that are not present in this mirror.
    dnf reposync \
        --repoid="${repo_id}" \
        --download-path="${dest}" \
        --newest-only \
        --arch="${ARCH},noarch" \
        --setopt=skip_if_unavailable=False

    # reposync normally creates a repository-ID subdirectory.
    local repo_dir="${dest}/${repo_id}"

    if [[ ! -d "${repo_dir}" ]]; then
        echo "Expected repository directory missing: ${repo_dir}" >&2
        return 1
    fi

    # Generate consistent metadata from the RPMs actually present.
    createrepo_c --update "${repo_dir}"

    log "Finished ${repo_id}"
}

main() {
    require_root

    enable_rhel_repos
    configure_third_party_repos
    download_gpg_keys

    sync_repo "${BASEOS}" "${MIRROR_ROOT}/baseos"
    sync_repo "${APPSTREAM}" "${MIRROR_ROOT}/appstream"
    sync_repo "${CODEREADY}" "${MIRROR_ROOT}/codeready"
    sync_repo "epel" "${MIRROR_ROOT}/epel"
    sync_repo "rpmfusion-free" "${MIRROR_ROOT}/rpmfusion-free"
    sync_repo "rpmfusion-nonfree" "${MIRROR_ROOT}/rpmfusion-nonfree"

    log "Mirror synchronization complete"
    log "Repository root: ${MIRROR_ROOT}"
    log "GPG keys: ${KEY_DIR}"
}

main "$@"