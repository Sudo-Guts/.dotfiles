#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/../install/lib.sh"
failures=0
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
for pair in "zsh/.zshrc|$HOME/.zshrc" "nvim|$config_dir/nvim" "kitty|$config_dir/kitty"; do
    source_path="$DOTFILES_ROOT/${pair%%|*}"; dest="${pair#*|}"
    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(realpath "$source_path")" ]]; then log "OK enlace $dest"
    else log "FALTA enlace $dest"; failures=$((failures+1)); fi
done
for cmd in zsh nvim kitty git gh fzf rg fd clangd clang-format gdb bear shellcheck tree-sitter iverilog vvp ghdl gtkwave; do
    if command -v "$cmd" >/dev/null; then log "OK $cmd: $(command -v "$cmd")"
    else log "FALTA $cmd"; failures=$((failures+1)); fi
done
export PATH="$PATH:${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"
for cmd in lua-language-server stylua shfmt verible-verilog-ls verible-verilog-format vhdl_ls codelldb; do
    if command -v "$cmd" >/dev/null; then log "OK $cmd"; else log "FALTA $cmd; ejecuta install/nvim-tools.sh"; failures=$((failures+1)); fi
done
if command -v zsh >/dev/null; then
    for file in "$DOTFILES_ROOT/zsh/.zshrc" "$DOTFILES_ROOT"/zsh/*.zsh; do zsh -n "$file" || failures=$((failures+1)); done
fi
if command -v nvim >/dev/null; then
    nvim --clean --headless '+lua if vim.fn.has("nvim-0.12") == 0 then vim.cmd("cquit 1") end' +qa || failures=$((failures+1))
fi
if command -v kitty >/dev/null; then
    current="$(kitty --version | awk '{print $2}')"
    version_ge "$current" "$KITTY_MIN_VERSION" || { log "Kitty requiere >= $KITTY_MIN_VERSION"; failures=$((failures+1)); }
fi
log "Comprobación terminada: $failures pendientes. En Neovim: :checkhealth"
(( failures == 0 ))
