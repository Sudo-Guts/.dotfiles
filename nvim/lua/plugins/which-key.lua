return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    win = { border = "rounded" },
    icons = {
      breadcrumb = "»",
      separator = "",
      group = "+",
      keys = { Space = "󱁐", Tab = "󰌒", Esc = "󱊷" },
    },
    spec = {
      { "<leader>f", group = "Buscar" },
      { "<leader>g", group = "Git" },
      { "<leader>c", group = "Código / compilar" },
      { "<leader>x", group = "Diagnósticos" },
      { "<leader>b", group = "Buffers" },
      { "<leader>d", group = "Depurar" },
      { "<leader>h", group = "Cambios (hunks)" },
      { "<leader>s", group = "Sesiones" },
      { "<leader>t", group = "Terminal / vista" },
    },
  },
}
