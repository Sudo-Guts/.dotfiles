return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  opts = {},
  keys = {
    { "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnósticos del proyecto" },
    { "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnósticos del buffer" },
    { "<leader>xq", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix" },
    { "<leader>xl", "<Cmd>Trouble loclist toggle<CR>", desc = "Lista local" },
    { "<leader>cs", "<Cmd>Trouble symbols toggle focus=false<CR>", desc = "Símbolos" },
    { "<leader>cL", "<Cmd>Trouble lsp toggle<CR>", desc = "Referencias y definiciones" },
  },
}
