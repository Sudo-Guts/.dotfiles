#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
require_command curl
current="$(kitty --version 2>/dev/null | awk '{print $2}' || true)"
if [[ -z "$current" ]] || ! version_ge "$current" "$KITTY_MIN_VERSION" || [[ "$DOTFILES_UPDATE" == 1 ]]; then
    work="$(mktemp -d)"; trap 'rm -rf -- "$work"' EXIT
    download https://sw.kovidgoyal.net/kitty/installer.sh "$work/installer.sh"
    sh "$work/installer.sh" "installer=version-$KITTY_VERSION" launch=n
fi
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
if [[ -x "$HOME/.local/kitty.app/bin/kitty" ]]; then
    for binary in kitty kitten; do ln -sfnT "$HOME/.local/kitty.app/bin/$binary" "$HOME/.local/bin/$binary"; done
    cat > "$HOME/.local/share/applications/kitty.desktop" <<EOF
[Desktop Entry]
Name=Kitty
Comment=Terminal GUTS
Exec="$HOME/.local/kitty.app/bin/kitty"
Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png
Type=Application
Categories=System;TerminalEmulator;
Terminal=false
EOF
fi
kitty --version
