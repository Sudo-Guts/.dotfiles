vim.g.mapleader = " "
vim.g.maplocalleader = ","
if vim.fn.has("nvim-0.12") == 0 then
  vim.api.nvim_echo({ { "GUTS requiere Neovim >= 0.12. Ejecuta install/nvim.sh", "ErrorMsg" } }, true, {})
  return
end
require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.lazy")
