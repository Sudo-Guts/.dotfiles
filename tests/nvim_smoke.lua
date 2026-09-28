-- Ejecutar mediante scripts/check.sh --nvim, después de instalar.
local root = assert(vim.env.DOTFILES_TEST_ROOT)
local function check()
  assert(package.loaded.lazy, "No se cargó la configuración GUTS")
  for _, file in ipairs(vim.fn.glob(root .. "/nvim/**/*.lua", false, true)) do
    assert(loadfile(file), "Error de sintaxis: " .. file)
  end
  local plugins = {}
  for name in pairs(require("lazy.core.config").plugins) do
    plugins[#plugins + 1] = name
  end
  require("lazy").load({ plugins = plugins })
  vim.wait(200)
  assert(vim.g.mapleader == " ")
  assert(vim.fn.maparg("<C-v>", "n") == "", "Ctrl+V debe conservar bloque visual")
  assert(vim.fn.maparg("<C-y>", "n", false, true).rhs == "<C-r>")
  assert(vim.fn.maparg("<leader>ff", "n") ~= "")
  assert(vim.fn.maparg("<leader>db", "n") ~= "")
  assert(#require("dap").configurations.c == 3)
  assert(require("cmp").get_config().sources[1].name == "nvim_lsp")
  for _, lang in ipairs(require("config.parsers")) do
    assert(vim.treesitter.language.add(lang), "Parser faltante: " .. lang)
  end
  for _, ft in ipairs({ "c", "cpp", "verilog", "systemverilog", "vhdl", "lua", "markdown" }) do
    vim.cmd.enew()
    vim.bo.filetype = ft
    vim.wait(50)
    local parser = vim.treesitter.get_parser(0)
    assert(parser and parser:parse()[1], "Parser no funciona en " .. ft)
  end
  print("PASS: sintaxis Lua, plugins, atajos, adaptadores, completion y parsers")
end
local ok, err = pcall(check)
if not ok then
  print(err)
  vim.cmd("cquit 1")
end
