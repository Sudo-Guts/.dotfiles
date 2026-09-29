#!/usr/bin/env bash

# ============================================================
# GUTS Dotfiles Bootstrap
# ============================================================
#
# Instalador principal del entorno.
#
# Responsabilidades:
#   - Validar el entorno de ejecución
#   - Reemplazar configuraciones gestionadas por el repositorio
#   - Crear enlaces simbólicos
#   - Ejecutar instaladores base
#   - Instalar componentes opcionales
#   - Ejecutar la verificación final
#
# IMPORTANTE:
#   Este script debe ejecutarse como usuario normal.
#   Los módulos individuales usan sudo únicamente cuando
#   necesitan modificar componentes del sistema.
#
# ============================================================

set -Eeuo pipefail


# ============================================================
# Shared Library
# ============================================================

source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"


# ============================================================
# Default Options
# ============================================================

mode="install"

with_docker=0
with_riscv=0
with_gnome=0
change_shell=0


# ============================================================
# Help
# ============================================================

usage() {
    cat <<'EOF'
Uso:

    bash install/bootstrap.sh [opciones]

Opciones:

    --link-only
        Solo reemplaza y enlaza las configuraciones gestionadas.

    --check
        Comprueba enlaces, herramientas y dependencias.

    --update
        Actualiza los componentes gestionados por los instaladores.

    --with-riscv
        Instala el toolchain bare-metal RISC-V, GDB y QEMU.

    --with-docker
        Instala Docker.
        No modifica automáticamente los grupos del usuario.

    --with-gnome
        Configura Ctrl+Alt+T para abrir Kitty en GNOME.

    --change-shell
        Cambia el shell predeterminado del usuario a Zsh.

    --help, -h
        Muestra esta ayuda.


Instalación predeterminada:

    - Dependencias base
    - Git y GitHub CLI
    - Zsh
    - Kitty
    - Neovim
    - Herramientas HDL
    - Iosevka Nerd Font
    - Herramientas de desarrollo de Neovim


Configuraciones gestionadas:

    ~/.zshrc
    ${XDG_CONFIG_HOME:-~/.config}/nvim
    ${XDG_CONFIG_HOME:-~/.config}/kitty


ADVERTENCIA:

    Las configuraciones existentes en esos destinos se
    REEMPLAZAN SIN RESPALDO.

    El repositorio es la fuente de verdad.

EOF
}


# ============================================================
# Arguments
# ============================================================

for arg in "$@"; do

    case "$arg" in

        --link-only)
            mode="links"
            ;;

        --check)
            mode="check"
            ;;

        --update)
            export DOTFILES_UPDATE=1
            ;;

        --with-riscv)
            with_riscv=1
            ;;

        --with-docker)
            with_docker=1
            ;;

        --with-gnome)
            with_gnome=1
            ;;

        --change-shell)
            change_shell=1
            ;;

        --help|-h)
            usage
            exit 0
            ;;

        *)
            die "Opción desconocida: $arg"
            ;;

    esac

done


# ============================================================
# Check Mode
# ============================================================

if [[ "$mode" == "check" ]]; then
    exec bash "$DOTFILES_ROOT/scripts/doctor.sh"
fi


# ============================================================
# Execution Safety
# ============================================================

# El bootstrap no debe ejecutarse directamente como root.
#
# DOTFILES_ALLOW_ROOT existe únicamente para pruebas aisladas.

if (( EUID == 0 )) &&
   [[ "${DOTFILES_ALLOW_ROOT:-0}" != "1" ]]; then

    die "Ejecuta bootstrap.sh como usuario normal, sin sudo."

fi


# ============================================================
# User Paths
# ============================================================

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ "$HOME" != /* ]] ||
   [[ "$HOME" == "/" ]] ||
   [[ "$config_dir" != /* ]] ||
   [[ "$config_dir" == "/" ]]; then

    die "Rutas de usuario inválidas."

fi


# ============================================================
# Managed Links
# ============================================================

# El bootstrap únicamente tiene permiso para reemplazar
# estos destinos.
#
# Mantener ambos arrays sincronizados.

sources=(
    "$DOTFILES_ROOT/zsh/.zshrc"
    "$DOTFILES_ROOT/nvim"
    "$DOTFILES_ROOT/kitty"
)

destinations=(
    "$HOME/.zshrc"
    "$config_dir/nvim"
    "$config_dir/kitty"
)


# ============================================================
# Preflight
# ============================================================

# Validar TODOS los enlaces antes de modificar el primero.
#
# Esto evita terminar con una instalación parcialmente
# reemplazada si alguno de los orígenes o destinos es inválido.

for i in "${!sources[@]}"; do

    source_path="${sources[i]}"
    destination="${destinations[i]}"

    # --------------------------------------------------------
    # Validate Source
    # --------------------------------------------------------

    source_real="$(
        realpath -e -- "$source_path"
    )" || die "Origen inexistente: $source_path"


    # --------------------------------------------------------
    # Resolve Destination
    # --------------------------------------------------------

    destination_parent="$(
        realpath -m -- "$(dirname -- "$destination")"
    )"

    destination_real="$destination_parent/$(basename -- "$destination")"


    # --------------------------------------------------------
    # Protect Repository
    # --------------------------------------------------------

    # Nunca permitir que un destino sea:
    #
    #   - el propio repositorio
    #   - un directorio que contiene al repositorio

    if [[ "$source_real" == "$destination_real" ]] ||
       [[ "$DOTFILES_ROOT" == "$destination_real" ]] ||
       [[ "$DOTFILES_ROOT" == "$destination_real/"* ]]; then

        die "El destino puede contener el repositorio: $destination"

    fi


    # --------------------------------------------------------
    # Protect Critical Paths
    # --------------------------------------------------------

    if [[ "$destination_real" == "/" ]] ||
       [[ "$destination_real" == "$HOME" ]]; then

        die "Destino protegido: $destination"

    fi

done


# ============================================================
# Safe Link
# ============================================================

safe_link() {
    local src="$1"
    local dst="$2"

    local managed=0
    local item


    # --------------------------------------------------------
    # Verify Manifest
    # --------------------------------------------------------

    # safe_link únicamente puede eliminar destinos declarados
    # explícitamente en el manifiesto.

    for item in "${destinations[@]}"; do

        if [[ "$dst" == "$item" ]]; then
            managed=1
            break
        fi

    done

    (( managed )) ||
        die "Destino fuera del manifiesto: $dst"


    # --------------------------------------------------------
    # Verify Source
    # --------------------------------------------------------

    [[ -e "$src" ]] ||
        die "Origen inexistente: $src"


    # --------------------------------------------------------
    # Already Correct
    # --------------------------------------------------------

    if [[ -L "$dst" ]] &&
       [[ "$(readlink -f -- "$dst" || true)" == "$(realpath -e -- "$src")" ]]; then

        log "Enlace correcto: $dst"
        return 0

    fi


    # --------------------------------------------------------
    # Create Parent Directory
    # --------------------------------------------------------

    mkdir -p -- "$(dirname -- "$dst")"


    # --------------------------------------------------------
    # Replace Existing Destination
    # --------------------------------------------------------

    if [[ -e "$dst" ]] || [[ -L "$dst" ]]; then

        log "Reemplazando: $dst"

        if [[ -L "$dst" ]] || [[ ! -d "$dst" ]]; then

            rm -f -- "$dst"

        else

            rm -rf \
                --one-file-system \
                -- "$dst"

        fi

    fi


    # --------------------------------------------------------
    # Create Symbolic Link
    # --------------------------------------------------------

    ln -sT -- "$src" "$dst"

    log "Enlace creado: $dst → $src"
}


# ============================================================
# Apply Managed Links
# ============================================================

for i in "${!sources[@]}"; do
    safe_link \
        "${sources[i]}" \
        "${destinations[i]}"
done


# ============================================================
# Link-only Mode
# ============================================================

if [[ "$mode" == "links" ]]; then

    log "Enlaces listos."
    exit 0

fi


# ============================================================
# Base Installation
# ============================================================

base_modules=(
    common
    git
    zsh
    kitty
    nvim
    vhri
    fonts
)

for module in "${base_modules[@]}"; do

    log "Instalando/comprobando: $module"

    bash "$DOTFILES_ROOT/install/$module.sh"

done


# ============================================================
# Optional Components
# ============================================================

if (( with_riscv )); then

    log "Instalando entorno RISC-V..."
    bash "$DOTFILES_ROOT/install/riscv.sh"

fi


if (( with_docker )); then

    log "Instalando Docker..."
    bash "$DOTFILES_ROOT/install/docker.sh"

fi


if (( with_gnome )); then

    log "Configurando integración con GNOME..."
    bash "$DOTFILES_ROOT/install/desktop.sh"

fi


# ============================================================
# Neovim Tools
# ============================================================

log "Instalando herramientas de Neovim..."

bash "$DOTFILES_ROOT/install/nvim-tools.sh"


# ============================================================
# Default Shell
# ============================================================

if (( change_shell )); then

    zsh_path="$(command -v zsh)"

    [[ -n "$zsh_path" ]] ||
        die "Zsh no está disponible."

    log "Cambiando shell predeterminado a: $zsh_path"

    chsh -s "$zsh_path"

fi


# ============================================================
# Final Verification
# ============================================================

log "Ejecutando comprobación final..."

bash "$DOTFILES_ROOT/scripts/doctor.sh"


# ============================================================
# Done
# ============================================================

log "Instalación terminada."
log "Abre una terminal nueva para aplicar completamente los cambios."
