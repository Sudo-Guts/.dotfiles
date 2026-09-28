return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = { "ConformInfo", "FormatToggle" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "x" },
      desc = "Formatear",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      c = { "clang_format" },
      cpp = { "clang_format" },
      verilog = { "verible" },
      systemverilog = { "verible" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    default_format_opts = { lsp_format = "fallback" },
    format_on_save = function(buf)
      if not vim.g.dotfiles_format_on_save or vim.b[buf].disable_autoformat then
        return
      end
      local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
      if stat and stat.size > 1024 * 1024 then
        return
      end
      return { timeout_ms = 2000, lsp_format = "fallback" }
    end,
  },
  config = function(_, opts)
    require("conform").setup(opts)
    vim.api.nvim_create_user_command("FormatToggle", function()
      vim.g.dotfiles_format_on_save = not vim.g.dotfiles_format_on_save
      vim.notify("Formato al guardar: " .. tostring(vim.g.dotfiles_format_on_save))
    end, {})
  end,
}
