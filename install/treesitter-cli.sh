#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
current="$(tree-sitter --version 2>/dev/null | awk '{print $2}' || true)"
if [[ -n "$current" ]] && version_ge "$current" 0.26.1 && [[ "$DOTFILES_UPDATE" == 0 ]]; then exit 0; fi
case "$(uname -m)" in x86_64) arch=x64;; aarch64|arm64) arch=arm64;; *) die 'Arquitectura Tree-sitter no soportada.';; esac
work="$(mktemp -d)"; trap 'rm -rf -- "$work"' EXIT
download "https://github.com/tree-sitter/tree-sitter/releases/download/$TREE_SITTER_VERSION/tree-sitter-cli-linux-$arch.zip" "$work/ts.zip"
unzip -q "$work/ts.zip" -d "$work/bin"
binary="$(find "$work/bin" -type f -name tree-sitter -print -quit)"
[[ -n "$binary" ]] || die 'El paquete no contiene tree-sitter.'
mkdir -p "$HOME/.local/bin"
install -m755 "$binary" "$HOME/.local/bin/tree-sitter"
tree-sitter --version
