# Verificación de la entrega

Fecha: 28 de septiembre de 2026. Entorno de pruebas: Linux x86_64, con HOME y
directorios XDG aislados. Las pruebas no se ejecutaron sobre tu computadora.

## Comprobaciones realizadas

| Área | Resultado observado |
|---|---|
| Instaladores | Sintaxis Bash correcta y ShellCheck 0.11.0 sin avisos de nivel warning/error. |
| Bootstrap | 8 pruebas automáticas aprobadas: instalación nueva, segunda ejecución sin recrear enlaces, reemplazo de archivos/directorios, enlaces rotos, destino equivocado sin borrar su contenido, origen ausente, protección del repositorio, opción inválida y ruta XDG con symlink. Algunos casos cubren más de una condición. |
| Zsh | Sintaxis correcta. Carga interactiva con OMZ y recarga de `.zshrc` sin duplicar hooks/rutas. Prompt probado dentro y fuera de Git; no escribe configuración global de Git al abrir el shell. |
| Kitty | El parser oficial de Kitty 0.49.1 aceptó la configuración completa sin líneas inválidas. |
| Plugins | 40 plugins fijados; restauración de commits completada. Carga explícita de todos los módulos sin errores de configuración. |
| Herramientas | Instalación real de los seis paquetes Mason con las versiones de `config/tools.lua`. El instalador comprueba también que los checkouts coincidan con el lockfile. |
| Treesitter | 22 parsers instalados con CLI 0.27.0. Parseo de buffers C, C++, Verilog, SystemVerilog, VHDL, Lua y Markdown comprobado. |
| LSP | Conexión real de clangd 18, Lua LS, Verible y VHDL LS en proyectos temporales. |
| Completion/diagnósticos | Se solicitó completion LSP en C y se comprobó la aparición de un símbolo del archivo; se introdujo un error C y se recibió el diagnóstico. |
| Formato | Formato de C, Lua y SystemVerilog ejecutado con sus herramientas. VHDL no tiene un formatter adicional prometido. |
| Simulación | Icarus Verilog 12 y GHDL 4.1 ejecutaron testbenches sencillos, con los mensajes de salida esperados. |
| Git/UI | Hunk de Gitsigns, preview, Diffview, Trouble, Neo-tree y Telescope abiertos en un repositorio temporal desde Neovim headless. |
| Atajos | Comprobados líderes, mapas principales, Ctrl+V nativo, Ctrl+Y en normal, completion y tres perfiles DAP. |
| Depuración | CodeLLDB arrancó y respondió al protocolo DAP. La ejecución del programa fue bloqueada por `ptrace failed: Operation not permitted`; no se da por validado el stepping. |
| Higiene | Formato Lua con StyLua, `git diff --check` y revisión del contenido del archivo comprimido. |

En la integración de VHDL se detectó y corrigió un problema de la plantilla:
`work` no es un nombre válido para definir la biblioteca del usuario en VHDL LS.
La plantilla entregada usa `defaultlib`. También se corrigió el nombre del
paquete Mason (`rust_hdl`) y el del parser actual (`systemverilog`).

## Medición de arranque

Se restauró por separado la configuración original del commit de base, con sus
25 plugins fijados. Se usó el mismo binario Neovim 0.12.5 para ambas versiones,
directorios XDG separados, un arranque de calentamiento y cinco muestras por
configuración, alternando original/entrega. Se midió la marca `NVIM STARTED`
de `--startuptime` en modo headless.

| Configuración | Muestras (ms) | Mediana |
|---|---|---|
| Original | 45.229, 50.679, 44.992, 56.571, 50.910 | 50.679 ms |
| Entrega | 22.250, 24.590, 25.768, 21.417, 22.753 | 22.753 ms |

En ese arranque se cargaron 21 de 25 plugins originales y 5 de 40 en la nueva
configuración. Los restantes se cargan por eventos, comandos, teclas o tipo de
archivo; la prueba separada de carga completa verifica sus configuraciones.
La medición se realizó antes del ajuste final que desactiva LuaRocks, que no
utiliza ningún plugin de este conjunto.

Esta medición no representa la latencia de todos los plugins al primer uso,
la de un LSP indexando un proyecto, el tiempo de descarga inicial ni una sesión
gráfica de Kitty. No se midió consumo de GPU. En tu equipo puedes usar
`nvim --startuptime /tmp/guts-nvim-startup.log` y `:Lazy profile` en una sesión
interactiva.

## Checkhealth y límites

Se ejecutaron los checks de Lazy, Mason, Treesitter, LSP, Conform y DAP, cargando
primero sus módulos. Treesitter y los seis paquetes Mason quedaron disponibles.
La instalación final aislada no incluye todos los paquetes apt del sistema:
el healthcheck señala la ausencia de GDB y clang-format en ese entorno, aunque
clangd/clang-format se probaron por separado con binarios extraídos de paquetes.
El bootstrap instala esas dependencias en el equipo de destino.

Mason puede mostrar avisos sobre Go, Ruby, Java, PHP, Rust u otros gestores que
no utiliza este conjunto. Lazy también detecta el directorio `site/pack/core`
creado por la instalación de parsers; no es una segunda copia de los plugins
del lockfile. No se instalan todos esos lenguajes solo para ocultar avisos.

No se ejecutaron en esta entrega:

- La instalación completa de paquetes sobre un Ubuntu/Debian limpio ni la
  variante arm64. Los scripts se revisaron y las pruebas de enlaces sí se
  ejecutaron sobre configuraciones temporales existentes.
- La compilación larga `riscv.sh --source`, ni la depuración RISC-V remota.
- Docker como servicio, los cambios de GNOME o el cambio de shell de una cuenta.
- La conexión física con tu FPGA, ISE, Digilent, OpenOCD o tu debugger UART.
- El renderizado de Kitty en tu escritorio, su clipboard, los atajos del gestor
  de ventanas y la apariencia de la fuente instalada.
- Los comandos de GitHub que publican, crean PRs, hacen push o requieren tu
  autenticación. Solo se implementaron; no se publicaron cambios en tu nombre.

## Repetir las comprobaciones

Después de instalar:

```bash
cd ~/.dotfiles
bash scripts/check.sh
bash scripts/check.sh --nvim
bash install/bootstrap.sh --check
```

`scripts/check.sh` ejecuta sintaxis, ShellCheck si está disponible y las ocho
pruebas de bootstrap. `--nvim` añade `tests/nvim_smoke.lua`, que carga los
plugins y comprueba parsers, adaptadores, completion y atajos. Las pruebas de
integración con servidores y simuladores descritas arriba fueron adicionales;
el smoke test no afirma sustituirlas.

Dentro de Neovim, consulta `:Lazy`, `:Mason`, `:checkhealth` y
`:checkhealth vim.lsp`. Abre un proyecto real antes de comprobar los clientes
LSP: una pantalla de inicio sin archivo no necesita tener servidores activos.
