# GUTS · Dotfiles

Entorno modular para Ubuntu/Debian, orientado a C/C++, HDL y firmware RISC-V.
Conserva el prompt personal, el dashboard GUTS y Catppuccin Mocha. Kitty utiliza
fondos estáticos; no contiene shaders.

## Empezar

El ZIP contiene un directorio **`.dotfiles`**, oculto por el punto inicial.
Activa «mostrar archivos ocultos» al descomprimir. Usa el directorio extraído
como tu nueva configuración; no lo superpongas sobre una copia vieja, porque
extraer un ZIP no elimina archivos obsoletos como `kitty/shaders/`.

Una vez colocado en `~/.dotfiles`:

```bash
cd ~/.dotfiles
bash install/bootstrap.sh
```

Ejecuta el script **sin sudo**. Solicitará la contraseña únicamente para los
paquetes o cambios del sistema que la necesiten. Se requiere conexión a Internet.
El objetivo de instalación es Ubuntu 24.04 o posterior / Debian moderno, en
x86_64 o arm64. Las pruebas de esta entrega se hicieron en Linux x86_64.

El instalador reemplaza **sin respaldos** estos destinos, tal como se acordó:

| Origen del repositorio | Destino |
|---|---|
| `zsh/.zshrc` | `~/.zshrc` |
| `nvim/` | `${XDG_CONFIG_HOME:-~/.config}/nvim` |
| `kitty/` | `${XDG_CONFIG_HOME:-~/.config}/kitty` |

Si el enlace ya es correcto, se conserva. Si el destino es otro enlace, se
elimina el enlace, no los datos a los que apuntaba. Si es un directorio real,
su contenido se reemplaza. Primero se validan los tres orígenes y destinos.
El repositorio puede vivir en otra ruta; los scripts la detectan.

## Opciones de instalación

```bash
# Solo aplicar las configuraciones, sin instalar paquetes.
bash install/bootstrap.sh --link-only

# Revisar enlaces, ejecutables y versiones mínimas.
bash install/bootstrap.sh --check

# Añadir compilador RISC-V, GDB multiarch y QEMU.
bash install/bootstrap.sh --with-riscv

# Componentes opcionales, combinables.
bash install/bootstrap.sh --with-docker --with-gnome --change-shell
```

La instalación base incluye Git/gh, Zsh/Oh My Zsh, fzf, Kitty, Neovim, Iosevka Nerd
Font, clangd/clang-format, GDB, Bear, Icarus Verilog, GHDL, GTKWave, ShellCheck y
las herramientas de Mason. No ejecuta `apt upgrade`, no altera el reloj ni
inicia sesión en GitHub. Docker es opcional y no cambia grupos de usuarios.
GNOME usa un atajo dedicado `Ctrl+Alt+T`; los otros atajos personalizados se conservan.

## Primera sesión

1. Abre una nueva terminal y ejecuta `zsh` si aún no cambiaste el shell.
2. Abre `nvim`. Usa `:Lazy`, `:Mason` y `:checkhealth` para consultar el estado.
3. Si se interrumpió la descarga de herramientas, ejecuta
   `bash install/nvim-tools.sh`. Dentro de Neovim también existe
   `:DotfilesToolsInstall`; después reinicia Neovim para activar los LSP nuevos.
4. Elige tu JPG en `kitty/background.conf`, siguiendo la sección siguiente.
5. Para GitHub, inicia sesión por tu cuenta con `gh auth login` cuando lo necesites.

## Kitty y tus fondos

Coloca tus imágenes en `kitty/backgrounds/`. Edita `kitty/background.conf`:

```conf
background_image backgrounds/mi-fondo.jpg
```

También admite una colección:

```conf
background_image backgrounds/*.jpg
```

Recarga Kitty con `Ctrl+Shift+F5`. `Ctrl+Shift+F11` y `Ctrl+Shift+F12` recorren la
colección. No hay temporizador de rotación ni animación de fondo.

Los JPG del repositorio original se conservaron en `backgrounds/`, pero no se
activan automáticamente porque pediste dejar los fondos estrellados. El estado
inicial usa el color Mocha (`background_image none`); selecciona la imagen que
quieras. La opacidad es 1.0 y el tinte 0.40; Neovim conserva fondos transparentes
para dejar visible la imagen de Kitty.

Copiar y pegar en Kitty usa `Ctrl+Shift+C/V`. `Ctrl+C` queda disponible para
interrumpir procesos; `Ctrl+S` llega a Neovim. Se eliminó el atajo `Shift+V` que
interceptaba una V mayúscula.

## Organización

| Directorio | Contenido |
|---|---|
| `install/` | Instaladores, versiones y utilidades compartidas |
| `zsh/` | `.zshrc`, `aliases.zsh`, `function.zsh`, `git.zsh` |
| `kitty/` | Configuración, selector de imagen y fondos |
| `nvim/lua/config/` | Opciones, teclas, tareas, herramientas y snippets |
| `nvim/lua/plugins/` | Un módulo por plugin o función |
| `examples/` | Plantillas por proyecto para HDL y clangd |
| `scripts/` | Diagnóstico, instalación de parsers y validación |
| `tests/` | Pruebas de reemplazo de enlaces y carga de Neovim |
| `docs/` | Atajos, flujos de trabajo, alcance y verificación |

## Actualizar y restaurar

```bash
# Revisa cambios de una actualización Git antes de volver a aplicar enlaces.
# Solo sirve si conservas tu propio checkout Git; el ZIP no incluye .git/.
git pull --ff-only

# Reaplica enlaces y actualiza instaladores/Oh My Zsh conforme al código actual.
bash install/bootstrap.sh --update

# Restaura los commits de plugins registrados en el lockfile.
nvim --headless '+Lazy! restore' +qa
bash install/nvim-tools.sh
```

`install/versions.sh` fija los binarios descargados. `nvim/lazy-lock.json` fija
los plugins y `nvim/lua/config/tools.lua` las versiones solicitadas a Mason.
Los paquetes apt siguen las versiones de la distribución. Las herramientas
externas que ya existen en el PATH se conservan; Mason no las duplica.

Para actualizar plugins deliberadamente usa `:Lazy update`, revisa el resultado
y guarda el nuevo `lazy-lock.json` en Git. Las instalaciones normales usan
`restore`, no actualizan todos los plugins cada vez. Para actualizar herramientas
Mason cambia la versión fijada y reinstala el paquete explícitamente desde Mason;
la instalación normal solo agrega lo que falta.

## Documentación

- [Atajos y funciones](docs/ATAJOS.md)
- [HDL, C/C++ y RISC-V](docs/FLUJOS.md)
- [Decisiones y cobertura del plan original](docs/ALCANCE.md)
- [Pruebas y límites de validación](docs/VERIFICACION.md)

```bash
bash scripts/check.sh           # Bash, Zsh, ShellCheck y pruebas de enlaces
bash scripts/check.sh --nvim    # Añade carga de plugins y parsers instalados
```

Base: `Sudo-Guts/.dotfiles`, commit `8eb6a989d6e9a0eea1a52b10294cac36e3c37ccf`.
El ZIP incluye el código y los JPG; plugins, fuentes y herramientas se descargan
al instalar. No incluye `.git/`, credenciales ni cachés de pruebas.
