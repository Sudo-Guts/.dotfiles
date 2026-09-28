# Cobertura del chat compartido

Base utilizada: `Sudo-Guts/.dotfiles`, commit
`8eb6a989d6e9a0eea1a52b10294cac36e3c37ccf`.
Esta tabla sigue los 46 puntos del plan. «Implementado» describe el código;
el alcance de las pruebas está en [VERIFICACION.md](VERIFICACION.md).

Se aplica la última decisión sobre Kitty: fondos JPG estáticos, sin shaders,
sin animaciones y sin activar las estrellas por defecto. Esa decisión sustituye
la propuesta anterior de crear un starfield animado.

| Nº | Tema | Resultado y ubicación |
|---|---|---|
| 1 | Bootstrap | Errores estrictos, preflight, reemplazo sin backups, enlaces correctos intactos, módulos y comprobación final en `install/bootstrap.sh`. |
| 2 | Dependencias base | `common.sh` activo; paquetes comunes, sin upgrades ni cambio de reloj. GNOME separado y opcional. |
| 3 | Git | `install/git.sh` configura push, prune, rebase, rerere, colores y orden; instala gh. Conserva identidad y credenciales. |
| 4 | Instalador Zsh | Un solo fzf desde apt; OMZ y plugins conservados; actualización explícita; no escribe `.zshrc`. |
| 5 | Loader Zsh | Rutas únicas, RISC-V/xPack, carga condicional, historial y hooks idempotentes en `zsh/.zshrc`. |
| 6 | Alias | `aliases.zsh` contiene alias y comentarios; conserva las categorías y evita colisiones con funciones propias. |
| 7 | Funciones | Prompt, Git, GitHub, ISE y Digilent en `function.zsh`; argumentos y dependencias comprobados. |
| 8 | Git visual | `git.zsh` solo contiene presentación. El prompt obtiene estado, ahead/behind y stash con una consulta local por actualización; no usa la cadena de consultas repetidas de OMZ. |
| 9 | Git/GitHub | Funciones bajo demanda y selectores fzf de ramas, commits y repositorios. Ninguna consulta de red en el prompt. |
| 10 | Instalar Kitty | Instalador oficial, versión mínima, PATH e integración de escritorio en `install/kitty.sh`. |
| 11 | Estructura Kitty | `kitty.conf`, `background.conf` y `backgrounds/`; eliminada la carpeta `shaders/`, corregidas opciones duplicadas e inválidas. |
| 12 | Visual Kitty | Solo imágenes estáticas, tinte 0.40, `cscaled`, opacidad 1.0 y atajos para cambiar imagen. Sin cursor trail ni parpadeo. |
| 13 | Base Neovim | Leaders antes de Lazy; opciones y mapas separados; undo persistente, búsquedas, splits, clipboard y conflictos de teclas corregidos. |
| 14 | Lazy | Carga por eventos/comandos/teclas/filetype, lockfile actualizado y restauración comprobada. Treesitter `main` se carga al inicio por su contrato actual. |
| 15 | Treesitter | Parsers de C/C++, Lua, Bash, HDL, Markdown, datos, Git, Make y CMake. `systemverilog` cubre `.v` y `.sv`; límite de tamaño. Textobjects queda como ampliación futura opcional. |
| 16 | Mason | UI y comando de instalación explícito. Versiones fijadas en `config/tools.lua`; herramientas del sistema tienen prioridad. |
| 17 | LSP | API nativa Neovim 0.12, clangd, Lua LS, Verible y VHDL LS; raíces, capabilities, diagnósticos y teclas en `LspAttach`. |
| 18 | Completion | Se conservan nvim-cmp y LuaSnip; se añade cmp_luasnip, friendly-snippets y snippets propios. Confirmación, ghost text y completion de comandos configurados. |
| 19 | Formato | Conform, formato al guardar/manual, StyLua, clang-format, Verible y shfmt; fallback LSP y toggle. No se inventa un formateador VHDL. |
| 20 | Lint | ShellCheck para Bash/sh mediante nvim-lint. clang-tidy mediante clangd y HDL mediante sus LSP, sin duplicar los diagnósticos. |
| 21 | Git en Neovim | Gitsigns con hunks, preview, stage/reset, blame y diff; colores Catppuccin y estado Git de Neo-tree. |
| 22 | Diffview | Vista de cambios, historial y comandos de comparación. `:DiffviewOpen rama` o `:DiffviewOpen commit1..commit2` aceptan revisiones concretas. |
| 23 | Trouble | Diagnósticos de workspace/buffer, símbolos, referencias/definiciones, quickfix y listas locales. |
| 24 | Depuración | DAP + UI + nvim-nio; CodeLLDB, GDB host y perfil RISC-V remoto. Breakpoints, pasos, variables, watches, stack y REPL. Véanse los límites de ejecución. |
| 25 | Telescope | ui-select, fzf-native, búsqueda de archivos/texto/buffers/Git/LSP, layout y exclusión de artefactos de compilación. |
| 26 | Neo-tree | Follow current file, ocultos, gitignored, cierre al quedar solo, símbolos y mappings; estructura de opciones corregida. |
| 27 | Bufferline | Navegación real de buffers, cierre/fijado, diagnósticos y offset Neo-tree; no confunde buffers con tabs. |
| 28 | Lualine | Catppuccin, Git, diagnósticos, archivo, encoding, filetype, progreso, ubicación y servidores LSP activos. |
| 29 | Which-key | Grupos para archivos, Git, código, diagnósticos, buffers, depuración, hunks, sesiones y herramientas; descripciones en mappings. |
| 30 | Noice/Notify | Notify como backend, paleta de comandos, mensajes y progreso LSP coordinados. |
| 31 | Flash | Salto y búsqueda estructural en Espacio j/J; conserva `s` y no captura Ctrl+S. |
| 32 | Grug-far | Reemplazos con ripgrep y atajo Espacio cR; rg instalado por common. |
| 33 | Markdown | render-markdown, mini.icons, Treesitter, límite de tamaño y toggle Espacio tm. |
| 34 | Alpha | Encabezado GUTS original; búsqueda, recientes, árbol del proyecto, sesiones, Lazy y Mason. |
| 35 | Catppuccin | Mocha transparente, integraciones nuevas y limpieza de integraciones no utilizadas. |
| 36 | Autocmds | Se retiró la escritura global de secuencias de escape; highlight al copiar y posición del cursor restaurada. No se recorta whitespace de forma indiscriminada. |
| 37 | HDL | LSP/formato/parsers, tareas Icarus/GHDL, quickfix, selector de ondas y plantillas por proyecto. |
| 38 | C/C++ y RISC-V | clangd, compile database, clang-format, clang-tidy, toolchain opcional y plantilla `.clangd` de RV32I separada de los flags host. |
| 39 | Terminal | Ventana terminal nativa reutilizable y tareas asíncronas. No se necesita ToggleTerm. |
| 40 | Sesiones | Persistence con guardado y restauración explícita. El selector usa `vim.ui.select`, integrado con Telescope ui-select. |
| 41 | Instalar Neovim | Tarball oficial x86_64/arm64, mínimo 0.12, CLI Treesitter, herramientas del sistema/Mason y enlace de configuración a cargo del bootstrap. |
| 42 | Instalar HDL | GHDL, GTKWave e Icarus desde apt; Verible y VHDL LS desde Mason; sin ejecutar todo el módulo con sudo. |
| 43 | Rendimiento | Carga diferida de plugins pesados y parsers sin descargas por archivo. Medición y condiciones en VERIFICACION.md; no se promete una cifra para tu equipo. |
| 44 | Consistencia visual | Paleta Mocha, transparencia, bordes redondeados e iconos Nerd Font. La comprobación visual final requiere tu escritorio. |
| 45 | Documentación | README nuevo, opciones, actualizaciones, fondos, atajos, flujos, plantillas, cobertura y pruebas. |
| 46 | Verificación | Pruebas de enlaces, ShellCheck, sintaxis, plugins, parsers, LSP, completion, formato, diagnósticos, UI Git y adaptador DAP; detalle y excepciones documentados. |

## Decisiones que requieren contexto

- **Nada de backups automáticos:** los tres destinos gestionados se reemplazan
  como pediste. Los demás directorios del usuario quedan fuera del manifiesto.
- **Versiones:** se fijan plugins, binarios descargados y solicitudes Mason.
  Apt y los clones de OMZ siguen sus repositorios; esto no es una imagen completa
  del sistema ni una instalación sin Internet.
- **RISC-V:** el camino normal usa paquetes de la distribución. La compilación
  larga de toolchain, Spike y pk se conserva como `riscv.sh --source`.
- **Depuración de tu CPU:** el perfil remoto necesita un GDB server que conozca
  tu objetivo. No se ha escrito un puente nuevo para tu protocolo UART ni una
  configuración de placa OpenOCD sin sus especificaciones.
- **HDL:** Icarus/GHDL son el flujo de simulación; no se simula un debugger RTL
  usando DAP. El testbench debe generar las ondas.
- **Cambios opcionales del plan:** se adoptó Persistence; se mantuvo cmp; se
  eligió terminal nativa; no se añadieron project.nvim, blink.cmp, textobjects ni
  linters redundantes. Las capturas de pantalla quedan para tu escritorio.
