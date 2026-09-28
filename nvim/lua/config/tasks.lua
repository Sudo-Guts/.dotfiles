local M = {}
local terminal_buf
function M.root()
  return vim.fs.root(
    0,
    { "Makefile", "makefile", "CMakeLists.txt", "verible.filelist", "vhdl_ls.toml", ".git" }
  ) or vim.fn.getcwd()
end
function M.terminal()
  if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
    local win = vim.fn.bufwinid(terminal_buf)
    if win ~= -1 then
      vim.api.nvim_win_close(win, false)
      return
    end
    vim.cmd("botright 14split")
    vim.api.nvim_win_set_buf(0, terminal_buf)
  else
    local cwd = M.root()
    vim.cmd("botright 14new")
    terminal_buf = vim.api.nvim_get_current_buf()
    vim.fn.jobstart(vim.o.shell, { term = true, cwd = cwd })
  end
  vim.cmd.startinsert()
end
function M.run(command, cwd, done)
  if vim.fn.executable(command[1]) == 0 then
    vim.notify("Falta " .. command[1], vim.log.levels.ERROR)
    return
  end
  vim.notify("Ejecutando: " .. table.concat(command, " "))
  vim.system(
    command,
    { cwd = cwd, text = true },
    vim.schedule_wrap(function(result)
      local output = (result.stdout or "") .. (result.stderr or "")
      -- Resolver rutas del compilador desde cwd sin cambiar el directorio del usuario.
      local lines = { "make: Entering directory '" .. cwd .. "'" }
      vim.list_extend(lines, vim.split(output, "\n", { trimempty = true }))
      lines[#lines + 1] = "make: Leaving directory '" .. cwd .. "'"
      vim.fn.setqflist(
        {},
        "r",
        { title = table.concat(command, " "), lines = lines, efm = vim.o.errorformat }
      )
      if result.code ~= 0 then
        vim.cmd.copen()
        vim.notify("Proceso falló: " .. result.code, vim.log.levels.ERROR)
      else
        vim.notify("Proceso terminado")
        if done then
          done()
        end
      end
    end)
  )
end
function M.make()
  local root = M.root()
  vim.cmd.wall()
  vim.ui.input({ prompt = "Objetivo make (vacío = predeterminado): " }, function(target)
    if target == nil then
      return
    end
    local cmd = { "make" }
    if target ~= "" then
      cmd[#cmd + 1] = target
    end
    M.run(cmd, root)
  end)
end
function M.verilog()
  vim.cmd.write()
  local root, file = M.root(), vim.api.nvim_buf_get_name(0)
  vim.ui.input({ prompt = "Módulo top del testbench: ", default = vim.fn.expand("%:t:r") }, function(top)
    if not top or top == "" then
      return
    end
    local build = root .. "/build/sim"
    vim.fn.mkdir(build, "p")
    local output = build .. "/simulation.vvp"
    local cmd = { "iverilog", "-g2012", "-s", top, "-o", output }
    if vim.fn.filereadable(root .. "/sim.f") == 1 then
      vim.list_extend(cmd, { "-f", "sim.f" })
    else
      cmd[#cmd + 1] = file
    end
    M.run(cmd, root, function()
      M.run({ "vvp", output }, root)
    end)
  end)
end
function M.vhdl()
  vim.cmd.write()
  local root, file = M.root(), vim.api.nvim_buf_get_name(0)
  vim.ui.input({ prompt = "Entidad top del testbench: ", default = vim.fn.expand("%:t:r") }, function(top)
    if not top or top == "" then
      return
    end
    local work = root .. "/build/ghdl"
    vim.fn.mkdir(work, "p")
    local cmd = { "ghdl", "-a", "--std=08", "--workdir=" .. work }
    local list = root .. "/vhdl.f"
    if vim.fn.filereadable(list) == 1 then
      for _, line in ipairs(vim.fn.readfile(list)) do
        line = vim.trim(line)
        if line ~= "" and line:sub(1, 1) ~= "#" then
          cmd[#cmd + 1] = line
        end
      end
    else
      cmd[#cmd + 1] = file
    end
    M.run(cmd, root, function()
      M.run({ "ghdl", "-e", "--std=08", "--workdir=" .. work, top }, root, function()
        M.run({
          "ghdl",
          "-r",
          "--std=08",
          "--workdir=" .. work,
          top,
          "--vcd=" .. work .. "/waves.vcd",
          "--stop-time=1ms",
        }, root)
      end)
    end)
  end)
end
function M.waves()
  vim.ui.input(
    { prompt = "Archivo VCD/FST/GHW: ", default = M.root() .. "/build/", completion = "file" },
    function(file)
      if not file or file == "" then
        return
      end
      if vim.fn.executable("gtkwave") == 0 then
        vim.notify("Falta gtkwave", vim.log.levels.ERROR)
        return
      end
      if vim.fn.filereadable(file) == 0 then
        vim.notify("No existe el archivo", vim.log.levels.ERROR)
        return
      end
      vim.fn.jobstart({ "gtkwave", file }, { detach = true })
    end
  )
end
return M
