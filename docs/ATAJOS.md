# Atajos y funciones

`<leader>` es **Espacio**. Por ejemplo, `<leader>ff` significa Espacio, f, f.
Los atajos LSP aparecen cuando el servidor está conectado al archivo.

## Neovim

| Atajo | Acción |
|---|---|
| `Ctrl+S`, `Espacio w` | Guardar |
| `Espacio q` | Cerrar ventana con confirmación si hay cambios |
| `Ctrl+Z` | Deshacer en modo normal/inserción |
| `Ctrl+Y` | Rehacer en normal; confirmar completion en inserción |
| `Ctrl+V` | Bloque visual nativo de Vim |
| `Espacio y` / `Espacio X` | Copiar/cortar selección al portapapeles |
| `Espacio p` | Pegar del portapapeles |
| `Ctrl+H/J/K/L` | Cambiar de ventana |
| `Espacio ff` / `fg` | Buscar archivos / texto |
| `Espacio fb` / `fr` | Buffers / archivos recientes |
| `Espacio fh` / `fG` | Ayuda / archivos Git |
| `Espacio fs` / `fR` | Símbolos / referencias LSP |
| `Espacio fd` | Buscar diagnósticos |
| `Espacio e` / `E` | Abrir árbol / revelar archivo actual |
| `H` dentro de Neo-tree | Alternar archivos ocultos |
| `Shift+H/L`, `Tab ,/.` | Buffer anterior/siguiente |
| `Espacio bd` / `bn` / `bp` | Cerrar / nuevo / fijar buffer |
| `gd`, `gr`, `gI`, `gy` | Definición, referencias, implementación, tipo |
| `K` | Documentación del símbolo |
| `Espacio cr` / `ca` / `ck` | Renombrar / acciones / firma |
| `Espacio ci` | Estado LSP |
| `Espacio cf` | Formatear archivo o selección |
| `:FormatToggle` | Activar/desactivar formato automático |
| `Espacio cR` | Buscar y reemplazar en el proyecto |
| `Espacio cs` / `cL` | Símbolos / lista de referencias y definiciones |
| `Espacio xx` / `xb` | Diagnósticos del proyecto / archivo |
| `Espacio xq` / `xl` | Quickfix / lista local |
| `]c` / `[c` | Cambio Git siguiente/anterior |
| `Espacio hs` / `hr` | Stage / restaurar hunk o selección |
| `Espacio hp` / `hb` / `hB` | Vista previa / blame / alternar blame |
| `Espacio hd` | Diff del archivo |
| `Espacio gd` / `gq` | Abrir/cerrar Diffview |
| `Espacio gH` | Historial del archivo |
| `Espacio gb` / `gc` | Buscar ramas / commits |
| `F5` / `Espacio dc` | Iniciar depuración o continuar |
| `F9` / `Espacio db` | Alternar breakpoint |
| `Espacio dB` | Breakpoint condicional |
| `F10` / `F11` / `F12` | Step over / into / out |
| `Espacio du` / `dr` / `de` | Paneles / REPL / evaluar expresión |
| `Espacio dq` | Terminar depuración |
| `Espacio tt` | Mostrar/ocultar terminal nativa |
| `Esc Esc` en terminal | Regresar al modo normal |
| `Espacio cm` | Ejecutar un objetivo de Make |
| `Espacio cv` / `ch` | Simulación Verilog/SV / VHDL |
| `Espacio cw` | Elegir archivo de ondas para GTKWave |
| `Espacio tm` | Alternar vista Markdown |
| `Espacio j` / `J` | Flash / selección estructural Treesitter |
| `Espacio sr` / `ss` / `sl` | Restaurar sesión actual / elegir / última |
| `Espacio sd` | No guardar esta sesión |

Completion: `Ctrl+N/P` selecciona, `Ctrl+Y` confirma, `Ctrl+E` cierra y
`Ctrl+Espacio` abre. Enter solo acepta un elemento seleccionado. Tab navega el
menú o expande un snippet; fuera de esos contextos conserva la tabulación.

Snippets añadidos: `modg` (módulo), `seqg` (registro con reset asíncrono activo
bajo) en Verilog/SV; `mainbare` en C. Son plantillas, no decisiones de arquitectura.
Se incluyen también friendly-snippets.

`Espacio hr` descarta los cambios del hunk: úsalo deliberadamente.

## Zsh / Git

Todos los alias están en `zsh/aliases.zsh`. Las funciones están en
`zsh/function.zsh`. `git.zsh` solo define presentación.

| Comando | Función |
|---|---|
| `Zsh`, `Kitty`, `Neovim`, `Dotfiles` | Abrir configuración / navegar |
| `gs`, `gss`, `gsb` | Estado Git |
| `ga`, `gaa`, `gc`, `gcm` | Agregar, agregar todo, commit, commit con mensaje |
| `gca` | Amend del último commit |
| `gp`, `gpf` | Push / push con force-with-lease |
| `gf`, `gfa`, `gpl`, `gpr` | Fetch, fetch de remotos, pull, pull rebase |
| `gd`, `gds`, `gl`, `gla`, `glg` | Diff e historial |
| `gac "mensaje"` | Agregar todo y commit |
| `gacp "mensaje"` | Agregar todo, commit y push |
| `gnew rama`, `gdel rama` | Crear / eliminar rama con comprobación de merge |
| `groot` | Ir a la raíz del repositorio |
| `gsync` | Fetch y pull rebase del upstream configurado |
| `ginfo` | Raíz, remotos y estado |
| `gcleanmerged` | Eliminar ramas fusionadas salvo main/master/develop/actual |
| `gpick`, `glpick` | Selector fzf de ramas / commits |
| `ghrepo`, `ghbranch`, `ghpr` | Abrir repo / rama / PR en navegador |
| `ghprc`, `ghinfo`, `ghpick` | Crear PR / información / selector de repositorios |
| `ise` | Iniciar Xilinx ISE desde su script de entorno |
| `digilent archivo.bit` | Detectar Nexys3 y programarla con djtgcfg |
| `dfcheck` | Diagnóstico del entorno |

`gac` y `gacp` incluyen todos los cambios del repositorio, como antes. `gpf`,
`gca` y los alias de eliminación conservan su semántica explícita de Git.
El prompt consulta estado local; no ejecuta fetch ni consulta GitHub.

ISE y Digilent requieren tus instalaciones externas. Puedes establecer
`XILINX_SETTINGS` para cambiar la ruta de `settings64.sh`.
