#!/usr/bin/env bash

# ============================================================
# Shared Installation Library
# ============================================================
#
# GUTS Dotfiles
#
# Funciones y variables compartidas por los scripts de:
#
#   install/
#
# Este archivo proporciona:
#
#   - Detección de la raíz del repositorio
#   - PATH del entorno de instalación
#   - Manejo de errores
#   - Ejecución privilegiada mediante sudo
#   - Instalación idempotente de paquetes APT
#   - Descargas HTTP
#   - Comparación de versiones
#   - Sincronización de repositorios Git
#
# ============================================================

set -Eeuo pipefail


# ============================================================
# Dotfiles Root
# ============================================================

DOTFILES_ROOT="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &&
    pwd -P
)"


# ============================================================
# Environment
# ============================================================

# Herramientas instaladas localmente tienen prioridad sobre
# versiones antiguas disponibles en el sistema.

export PATH="$HOME/.local/bin:$HOME/.local/kitty.app/bin:$PATH"

# Se establece desde bootstrap.sh mediante --update.
DOTFILES_UPDATE="${DOTFILES_UPDATE:-0}"


# ============================================================
# Versions
# ============================================================

source "$DOTFILES_ROOT/install/versions.sh"


# ============================================================
# Logging
# ============================================================

log() {
    printf '[dotfiles] %s\n' "$*"
}


die() {
    printf '[error] %s\n' "$*" >&2
    exit 1
}


# ============================================================
# Error Reporting
# ============================================================

# Muestra archivo, línea y comando cuando un script gestionado
# por esta librería termina debido a set -e.

trap '
    printf "[error] %s:%s: %s\n" \
        "${BASH_SOURCE[0]}" \
        "$LINENO" \
        "$BASH_COMMAND" >&2
' ERR


# ============================================================
# Privileged Commands
# ============================================================

as_root() {
    if (( EUID == 0 )); then
        "$@"
    else
        sudo -- "$@"
    fi
}


# ============================================================
# Command Validation
# ============================================================

require_command() {
    local command_name="$1"

    command -v "$command_name" >/dev/null 2>&1 ||
        die "Falta $command_name; ejecuta install/common.sh."
}


# ============================================================
# APT Packages
# ============================================================

apt_install() {
    require_command apt-get

    local missing=()
    local package


    # --------------------------------------------------------
    # Find Missing Packages
    # --------------------------------------------------------

    for package in "$@"; do

        if ! dpkg-query \
            -W \
            -f='${Status}' \
            "$package" \
            2>/dev/null |
            grep -qx 'install ok installed'; then

            missing+=("$package")

        fi

    done


    # --------------------------------------------------------
    # Nothing to Install
    # --------------------------------------------------------

    if (( ${#missing[@]} == 0 )); then
        return 0
    fi


    # --------------------------------------------------------
    # Install Missing Packages
    # --------------------------------------------------------

    log "Instalando paquetes: ${missing[*]}"

    as_root apt-get update

    as_root apt-get install \
        -y \
        --no-install-recommends \
        "${missing[@]}"
}


# ============================================================
# Downloads
# ============================================================

download() {
    local url="$1"
    local destination="$2"

    require_command curl

    curl \
        --fail \
        --location \
        --show-error \
        --silent \
        --retry 3 \
        --connect-timeout 20 \
        "$url" \
        -o "$destination"
}


# ============================================================
# Version Comparison
# ============================================================

version_ge() {
    local current="$1"
    local required="$2"

    [[ "$(
        printf '%s\n%s\n' "$current" "$required" |
            sort -V |
            head -n1
    )" == "$required" ]]
}


# ============================================================
# Git Repository Synchronization
# ============================================================

sync_repo() {
    local url="$1"
    local destination="$2"

    require_command git


    # --------------------------------------------------------
    # First Installation
    # --------------------------------------------------------

    if [[ ! -e "$destination" ]]; then

        log "Clonando: $url"

        command git clone \
            --depth 1 \
            "$url" \
            "$destination"

        return 0

    fi


    # --------------------------------------------------------
    # Validate Existing Destination
    # --------------------------------------------------------

    if [[ ! -d "$destination/.git" ]]; then
        die "$destination existe y no es un repositorio Git."
    fi


    # --------------------------------------------------------
    # Normal Installation
    # --------------------------------------------------------

    # Sin --update se conserva exactamente el checkout actual.

    if [[ "$DOTFILES_UPDATE" != "1" ]]; then
        return 0
    fi


    # --------------------------------------------------------
    # Protect Local Changes
    # --------------------------------------------------------

    if [[ -n "$(command git -C "$destination" status --porcelain)" ]]; then
        die "Hay cambios locales en $destination."
    fi


    # --------------------------------------------------------
    # Update Repository
    # --------------------------------------------------------

    log "Actualizando: $destination"

    command git -C "$destination" pull --ff-only
}
