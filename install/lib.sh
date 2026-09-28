#!/usr/bin/env bash
set -Eeuo pipefail
DOTFILES_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
export PATH="$HOME/.local/bin:$HOME/.local/kitty.app/bin:$PATH"
DOTFILES_UPDATE="${DOTFILES_UPDATE:-0}"
source "$DOTFILES_ROOT/install/versions.sh"
log() { printf '[dotfiles] %s\n' "$*"; }
die() { printf '[error] %s\n' "$*" >&2; exit 1; }
trap 'printf "[error] %s:%s: %s\n" "${BASH_SOURCE[0]}" "$LINENO" "$BASH_COMMAND" >&2' ERR
as_root() { if (( EUID == 0 )); then "$@"; else sudo -- "$@"; fi; }
require_command() { command -v "$1" >/dev/null || die "Falta $1; ejecuta install/common.sh."; }
apt_install() {
    require_command apt-get
    local missing=() package
    for package in "$@"; do
        if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -qx 'install ok installed'; then missing+=("$package"); fi
    done
    if (( ${#missing[@]} )); then
        as_root apt-get update
        as_root apt-get install -y --no-install-recommends "${missing[@]}"
    fi
}
download() { curl --fail --location --show-error --silent --retry 3 --connect-timeout 20 "$1" -o "$2"; }
version_ge() { [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$2" ]]; }
sync_repo() {
    local url="$1" dest="$2"
    if [[ ! -e "$dest" ]]; then git clone --depth 1 "$url" "$dest"
    elif [[ ! -d "$dest/.git" ]]; then die "$dest existe y no es un checkout Git."
    elif [[ "$DOTFILES_UPDATE" == 1 ]]; then
        [[ -z "$(git -C "$dest" status --porcelain)" ]] || die "Hay cambios locales en $dest."
        git -C "$dest" pull --ff-only
    fi
}
