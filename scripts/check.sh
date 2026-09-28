#!/usr/bin/env bash
set -Eeuo pipefail
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
for file in "$repo"/install/*.sh "$repo"/scripts/*.sh; do bash -n "$file"; done
if command -v shellcheck >/dev/null; then
    shellcheck -S warning -e SC1091 "$repo"/install/*.sh "$repo"/scripts/*.sh
else
    printf 'ShellCheck no está instalado; solo se comprobó sintaxis Bash.\n'
fi
for file in "$repo/zsh/.zshrc" "$repo"/zsh/*.zsh; do zsh -n "$file"; done
python3 "$repo/tests/test_bootstrap.py"
if [[ "${1:-}" == --nvim ]]; then
    config="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
    [[ "$(realpath -e "$config")" == "$repo/nvim" ]] || { printf 'Enlaza esta configuración antes de probar Neovim.\n' >&2; exit 1; }
    DOTFILES_TEST_ROOT="$repo" nvim --headless \
        -c 'lua dofile(vim.env.DOTFILES_TEST_ROOT .. "/tests/nvim_smoke.lua")' +qa
fi
