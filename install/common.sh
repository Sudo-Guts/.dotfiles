#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
apt_install ca-certificates curl wget git unzip xz-utils jq ripgrep fd-find fzf \
    build-essential bear cmake ninja-build pkg-config python3 python3-venv \
    fontconfig xclip wl-clipboard shellcheck tree
mkdir -p "$HOME/.local/bin"
if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
    ln -sfnT "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
log 'Dependencias listas; sin apt upgrade ni cambios al reloj.'
