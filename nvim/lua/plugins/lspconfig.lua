return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "hrsh7th/cmp-nvim-lsp", "mason-org/mason.nvim" },
  config = function()
    vim.lsp.config("*", { capabilities = require("cmp_nvim_lsp").default_capabilities() })
    local clangd_cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" }
    -- Lista de compiladores autorizados explícitamente; nunca un wildcard global.
    local drivers = vim.g.dotfiles_clangd_query_drivers or {}
    if #drivers > 0 then
      table.insert(clangd_cmd, "--query-driver=" .. table.concat(drivers, ","))
    end
    vim.lsp.config("clangd", { cmd = clangd_cmd })
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.config("verible", { root_markers = { "verible.filelist", ".git" } })
    vim.lsp.config("vhdl_ls", { filetypes = { "vhdl" }, root_markers = { "vhdl_ls.toml", ".git" } })
    local servers = {
      clangd = "clangd",
      lua_ls = "lua-language-server",
      verible = "verible-verilog-ls",
      vhdl_ls = "vhdl_ls",
    }
    for server, executable in pairs(servers) do
      if vim.fn.executable(executable) == 1 then
        vim.lsp.enable(server)
      end
    end
    vim.diagnostic.config({
      severity_sort = true,
      virtual_text = { spacing = 2, prefix = "●" },
      float = { border = "rounded", source = true },
      signs = { text = { [1] = "", [2] = "", [3] = "", [4] = "󰌵" } },
    })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("GutsLsp", { clear = true }),
      callback = function(args)
        local function map(key, action, desc)
          vim.keymap.set("n", key, action, { buffer = args.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Definición")
        map("gr", vim.lsp.buf.references, "Referencias")
        map("gI", vim.lsp.buf.implementation, "Implementación")
        map("gy", vim.lsp.buf.type_definition, "Definición del tipo")
        map("K", vim.lsp.buf.hover, "Documentación")
        map("<leader>cr", vim.lsp.buf.rename, "Renombrar símbolo")
        map("<leader>ca", vim.lsp.buf.code_action, "Acciones de código")
        map("<leader>ck", vim.lsp.buf.signature_help, "Firma de función")
        map("<leader>ci", "<Cmd>checkhealth vim.lsp<CR>", "Estado LSP")
      end,
    })
  end,
}
