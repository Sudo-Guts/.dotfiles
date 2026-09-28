#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
require_command curl
current="$(nvim --version 2>/dev/null | sed -n '1s/NVIM v//p' || true)"
if [[ -n "$current" ]] && version_ge "$current" "$NVIM_MIN_VERSION" && [[ "$DOTFILES_UPDATE" == 0 ]]; then
    log "Neovim $current satisface el mínimo."
else
    case "$(uname -m)" in x86_64) arch=x86_64;; aarch64|arm64) arch=arm64;; *) die 'Arquitectura Neovim no soportada.';; esac
    work="$(mktemp -d)"; trap 'rm -rf -- "$work"' EXIT
    download "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$arch.tar.gz" "$work/nvim.tar.gz"
    tar --no-same-owner -xzf "$work/nvim.tar.gz" -C "$work"
    "$work/nvim-linux-$arch/bin/nvim" --version
    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
    target="$HOME/.local/opt/nvim-$NVIM_VERSION"
    if [[ ! -d "$target" ]]; then mv "$work/nvim-linux-$arch" "$target"; fi
    ln -sfnT "$target/bin/nvim" "$HOME/.local/bin/nvim"
fi
apt_install clangd clang-format gdb
bash "$DOTFILES_ROOT/install/treesitter-cli.sh"
