# Flujos de trabajo

## Herramientas y responsabilidades

| Función | Responsable |
|---|---|
| Plugins | Lazy, con `lazy-lock.json` |
| Parsers | Treesitter `main`, Neovim >= 0.12 y tree-sitter CLI >= 0.26.1 |
| clangd, clang-format, GDB, ShellCheck, simuladores | Paquetes del sistema |
| Lua LS, StyLua, shfmt, Verible, VHDL LS y CodeLLDB | Mason, si no están ya en PATH |
| Formato al guardar/manual | Conform |
| Diagnósticos C/C++ | clangd, incluido clang-tidy |
| Diagnósticos HDL | Verible / VHDL LS |
| Diagnósticos de shell Bash/sh | nvim-lint + ShellCheck |
| Sesiones | Persistence, restauración explícita |
| Terminal y procesos de simulación | Funciones nativas de Neovim |

No se pasa Zsh a ShellCheck. No se duplica el lint de Verible mediante nvim-lint.
VHDL no tiene un formateador adicional configurado: Conform puede usar un LSP
si este ofrece formato. No se promete formato VHDL si el servidor no lo soporta.

La primera instalación descarga las herramientas y compila los parsers; tarda
más que un arranque normal. No hay descarga automática de parsers al abrir cada
archivo. Los archivos de más de 1 MiB evitan Treesitter y autoformato.

## C y C++

Abre Neovim desde la raíz del proyecto. clangd utiliza `compile_commands.json`.
Puedes producirlo con CMake:

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -s build/compile_commands.json compile_commands.json
```

O con Bear, realizando una compilación real:

```bash
bear -- make
```

Si Make no recompila nada, Bear no tendrá comandos que registrar. Los includes,
defines y flags pertenecen al proyecto. Conform respeta `.clang-format` cuando
existe; en otro caso usa los valores predeterminados de clang-format.

## Verilog y SystemVerilog

El parser actual de Treesitter es **systemverilog**, asociado a ambos filetypes.
Verible aporta LSP, lint y formato. En proyectos de varios módulos, adapta
`examples/verible.filelist` y `examples/sim.f` y colócalos en la raíz.

`Espacio cv` guarda el archivo, pide el módulo top y ejecuta Icarus con `-g2012`.
Si existe `sim.f`, se utiliza la lista; en caso contrario se compila solo el
archivo actual. El ejecutable se escribe en `build/sim/simulation.vvp` y luego
se ejecuta `vvp`. Los mensajes se envían a quickfix.

La simulación no genera ondas por sí sola. El testbench debe declarar
`$dumpfile` y `$dumpvars`. `Espacio cw` permite abrir el VCD/FST/GHW en GTKWave.
Para flujos más complejos, usa el Makefile del proyecto con `Espacio cm`.

## VHDL

Adapta `examples/vhdl_ls.toml` a tus bibliotecas. El nombre de la biblioteca del
usuario debe ser algo como **defaultlib**, no `work`, que es un nombre especial
para VHDL LS. Mason llama al paquete `rust_hdl`, aunque el ejecutable es `vhdl_ls`.

Para simular varios archivos, coloca `vhdl.f` en la raíz, una ruta por línea,
en orden de dependencias. `Espacio ch` ejecuta análisis, elaboración y simulación
con GHDL, VHDL-2008. El directorio de trabajo es `build/ghdl`, con `waves.vcd`.
La tarea integrada tiene `--stop-time=1ms`; usa tu Makefile para otro tiempo,
estándar, genéricos o bibliotecas.

## RISC-V y tu CPU RV32I

```bash
bash install/riscv.sh
```

Instala el compilador bare-metal, binutils, GDB multiarch y QEMU desde apt. Un
compilador llamado `riscv64-unknown-elf-gcc` puede generar RV32I si admite la
combinación, que debes indicar con `-march=rv32i -mabi=ilp32`. Comprueba las
bibliotecas disponibles con `-print-multi-lib`. El paquete del sistema no
sustituye tu startup, linker script, mapa de memoria ni bibliotecas bare-metal.

Mantuvimos `RISCV=/opt/riscv` y soporte para tu ruta xPack. Si existe más de una
toolchain, `command -v riscv64-unknown-elf-gcc` muestra cuál resuelve el PATH.
El orden es: herramientas locales, Kitty, `/opt/riscv`, compilación local,
xPack y PATH del sistema; Mason se agrega al final.

`examples/.clangd` es una plantilla exclusiva de RV32I. Adapta también la base
de compilación; no copies esos flags a proyectos C del equipo ni al TM4C129.
Si clangd debe consultar un compilador cruzado para descubrir includes, agrega
en `nvim/lua/config/options.lua` una ruta explícita:

```lua
vim.g.dotfiles_clangd_query_drivers = { "/opt/riscv/bin/riscv64-unknown-elf-gcc" }
```

El modo opcional de compilación desde fuentes conserva Spike y Proxy Kernel:

```bash
bash install/riscv.sh --source
```

Construye una toolchain multilib RV32I/ILP32 y RV64GC/LP64D, Spike y pk RV64.
Usa `~/.local/opt/riscv`, dos trabajos de compilación y caché en
`~/.cache/dotfiles/riscv`. No elimina `/opt/riscv`. `RISCV_BUILD_PREFIX` y
`DOTFILES_JOBS` permiten ajustar prefijo y paralelismo. Conserva marcadores de
componentes terminados y no los recompila en cada ejecución. Es una compilación
larga; no forma parte de la instalación predeterminada ni fue ejecutada en esta
entrega. Sus repositorios fuente siguen la revisión obtenida al clonarlos.

pk es un entorno para programas sobre Spike; no corresponde al firmware de tu
CPU RV32I. QEMU tampoco reproduce automáticamente tu periférico UART, debugger
o mapa de memoria personalizados.

## Depuración

Para un programa C/C++ del equipo, compila con `-g -O0`, presiona F5 y elige
CodeLLDB. Selecciona el ejecutable, marca breakpoints con F9 y usa F10/F11/F12.
También está preparada una configuración para GDB >= 14 compilado con soporte
DAP/Python.

Para RISC-V, inicia por separado un GDB server compatible con tu objetivo.
El perfil «RISC-V: conectar a GDB server» pide ELF y dirección `host:puerto`;
usa `gdb-multiarch` por defecto. Puedes fijar otra ruta con:

```lua
vim.g.dotfiles_riscv_gdb = "/ruta/a/riscv64-unknown-elf-gdb"
```

Ese GDB debe soportar `--interpreter=dap`. El perfil hace attach mediante
`target remote`; no carga firmware ni reinicia la placa. OpenOCD requiere un
adaptador y configuración de placa concretos. Tu debugger UART actual necesita
hablar el protocolo remoto de GDB o tener un puente adecuado para este flujo;
instalar DAP por sí solo no lo convierte en un GDB server.

No se configura DAP para HDL: simulación RTL y depuración de software son flujos
distintos. La limitación de ejecución observada aquí está en VERIFICACION.md.
