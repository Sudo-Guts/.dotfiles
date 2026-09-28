return {
  "mfussenegger/nvim-dap",
  cmd = { "DapContinue", "DapToggleBreakpoint" },
  dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio", "mason-org/mason.nvim" },
  keys = {
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Depurar / continuar",
    },
    {
      "<F9>",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Breakpoint",
    },
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Siguiente línea",
    },
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Entrar",
    },
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Salir de función",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Breakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Condición: "))
      end,
      desc = "Breakpoint condicional",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "Continuar",
    },
    {
      "<leader>dq",
      function()
        require("dap").terminate()
      end,
      desc = "Terminar depuración",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.toggle()
      end,
      desc = "Consola DAP",
    },
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "Paneles DAP",
    },
    {
      "<leader>de",
      function()
        require("dapui").eval()
      end,
      mode = { "n", "x" },
      desc = "Evaluar expresión",
    },
  },
  config = function()
    local dap, ui = require("dap"), require("dapui")
    ui.setup({ floating = { border = "rounded" } })
    dap.listeners.after.event_initialized.guts = function()
      ui.open()
    end
    dap.listeners.before.event_terminated.guts = function()
      ui.close()
    end
    dap.listeners.before.event_exited.guts = function()
      ui.close()
    end
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    dap.adapters.codelldb = function(callback)
      local executable = vim.fn.exepath("codelldb")
      if executable == "" then
        error("Falta codelldb: ejecuta :DotfilesToolsInstall")
      end
      callback({
        type = "server",
        port = "${port}",
        executable = { command = executable, args = { "--port", "${port}" } },
      })
    end
    dap.adapters.gdb = { type = "executable", command = "gdb", args = { "--interpreter=dap", "--quiet" } }
    dap.adapters.riscv_gdb = function(callback)
      local exe = vim.g.dotfiles_riscv_gdb or "gdb-multiarch"
      if vim.fn.executable(exe) == 0 then
        error("No existe " .. exe .. ". Instala GDB >= 14 con DAP y soporte RISC-V.")
      end
      callback({ type = "executable", command = exe, args = { "--interpreter=dap", "--quiet" } })
    end
    local function program()
      local name = vim.fn.input("Ejecutable / ELF: ", vim.fn.getcwd() .. "/", "file")
      if name == "" then
        return dap.ABORT
      end
      return vim.fn.fnamemodify(name, ":p")
    end
    dap.configurations.c = {
      {
        name = "C/C++ local (CodeLLDB)",
        type = "codelldb",
        request = "launch",
        program = program,
        cwd = "${workspaceFolder}",
        stopOnEntry = true,
      },
      {
        name = "C/C++ local (GDB >= 14)",
        type = "gdb",
        request = "launch",
        program = program,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = true,
      },
      {
        name = "RISC-V: conectar a GDB server",
        type = "riscv_gdb",
        request = "attach",
        program = program,
        target = function()
          return vim.fn.input("GDB server host:puerto: ", "localhost:3333")
        end,
      },
    }
    dap.configurations.cpp = dap.configurations.c
    dap.configurations.asm = dap.configurations.c
    -- No inicia OpenOCD/QEMU ni programa la FPGA automáticamente.
  end,
}
