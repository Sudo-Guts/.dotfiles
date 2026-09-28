#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
require_command nvim
require_command tree-sitter
# restore respeta lazy-lock.json; actualizar plugins es una acción distinta.
nvim --headless '+Lazy! restore' +qa
DOTFILES_TOOLS_SCRIPT="$DOTFILES_ROOT/scripts/nvim-tools.lua" nvim --headless \
  -c 'lua local ok,e=pcall(dofile,vim.env.DOTFILES_TOOLS_SCRIPT); if not ok then print(e); vim.cmd("cquit 1") end' +qa
