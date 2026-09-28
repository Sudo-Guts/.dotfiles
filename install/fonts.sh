#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
require_command unzip
font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/IosevkaNerdFont"
if [[ -f "$font_dir/.version" && "$(cat "$font_dir/.version")" == "$NERD_FONT_VERSION" && "$DOTFILES_UPDATE" == 0 ]]; then exit 0; fi
work="$(mktemp -d)"; trap 'rm -rf -- "$work"' EXIT
download "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONT_VERSION/Iosevka.zip" "$work/font.zip"
mkdir -p "$font_dir"
unzip -qo "$work/font.zip" -d "$font_dir"
printf '%s\n' "$NERD_FONT_VERSION" > "$font_dir/.version"
fc-cache "$font_dir"
