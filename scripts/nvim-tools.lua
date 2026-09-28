-- Lazy puede notificar un fallo sin cambiar el código de salida del editor.
-- Verificar el checkout evita dar por terminada una restauración incompleta.
local lock =
  vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
for name, plugin in pairs(require("lazy.core.config").plugins) do
  local expected = assert(lock[name], "Plugin sin versión fijada: " .. name)
  local result = vim.system({ "git", "-C", plugin.dir, "rev-parse", "HEAD" }, { text = true }):wait()
  if result.code ~= 0 or vim.trim(result.stdout or "") ~= expected.commit then
    error("Restauración incompleta de " .. name .. "; revisa :Lazy y ejecuta Lazy restore")
  end
end
require("lazy").load({ plugins = { "mason.nvim", "nvim-treesitter" } })
require("config.tools").install(true)
require("nvim-treesitter").install(require("config.parsers")):wait(600000)
local missing = {}
for _, lang in ipairs(require("config.parsers")) do
  local ok, loaded = pcall(vim.treesitter.language.add, lang)
  if not ok or not loaded then
    missing[#missing + 1] = lang
  end
end
if #missing > 0 then
  error("Parsers faltantes: " .. table.concat(missing, ", "))
end
print("Herramientas Mason y parsers listos.")
