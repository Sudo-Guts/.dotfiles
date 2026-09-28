local M = {}
-- clangd, clang-format, shellcheck: sistema. Estos paquetes: Mason.
M.packages = {
  { "lua-language-server", "lua-language-server", "3.19.1" },
  { "stylua", "stylua", "v2.5.2" },
  { "shfmt", "shfmt", "v3.14.1" },
  { "verible", "verible-verilog-ls", "v0.0-4296-g0f262651" },
  { "rust_hdl", "vhdl_ls", "v0.88.0" },
  { "codelldb", "codelldb", "v1.12.3" },
}
function M.install(wait)
  local registry = require("mason-registry")
  local finished, failed = false, {}
  registry.refresh(function(ok)
    if not ok then
      failed[#failed + 1] = "registro Mason"
      finished = true
      return
    end
    local remaining = 0
    for _, entry in ipairs(M.packages) do
      local name, executable, version = unpack(entry)
      if vim.fn.executable(executable) == 0 then
        local exists, pkg = pcall(registry.get_package, name)
        if not exists then
          failed[#failed + 1] = name
        elseif not pkg:is_installed() then
          remaining = remaining + 1
          pkg:install(
            { version = version },
            vim.schedule_wrap(function(success)
              if not success then
                failed[#failed + 1] = name
              end
              remaining = remaining - 1
              if remaining == 0 then
                finished = true
              end
            end)
          )
        end
      end
    end
    if remaining == 0 then
      finished = true
    end
  end)
  if wait then
    if not vim.wait(600000, function()
      return finished
    end, 100) then
      error("Tiempo agotado instalando herramientas Mason")
    end
    if #failed > 0 then
      error("No se instalaron: " .. table.concat(failed, ", "))
    end
  else
    vim.notify("Instalación iniciada; revisa :Mason y reinicia Neovim al terminar.")
  end
end
return M
