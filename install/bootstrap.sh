#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
mode=install
with_docker=0 with_riscv=0 with_gnome=0 change_shell=0
usage() {
    cat <<'EOF'
Uso: bash install/bootstrap.sh [opciones]
  --link-only       Solo reemplaza/enlaza los tres destinos de configuración.
  --check           Comprueba enlaces y herramientas.
  --update          Actualiza los componentes gestionados.
  --with-riscv      Instala toolchain bare-metal y GDB/QEMU.
  --with-docker     Instala Docker (no cambia grupos de usuarios).
  --with-gnome      Configura Ctrl+Alt+T para Kitty en GNOME.
  --change-shell    Cambia el shell de la cuenta a Zsh.
  --help            Muestra esta ayuda.
Sin opciones: base, Git/GitHub CLI, Zsh, Kitty, Neovim, HDL y Nerd Font.
REEMPLAZA sin respaldos ~/.zshrc, $XDG_CONFIG_HOME/nvim y .../kitty.
Ejecutar sin sudo. Los módulos elevan solo los comandos necesarios.
EOF
}
for arg in "$@"; do
    case "$arg" in
        --link-only) mode=links;; --check) mode=check;; --update) export DOTFILES_UPDATE=1;;
        --with-docker) with_docker=1;; --with-riscv) with_riscv=1;;
        --with-gnome) with_gnome=1;; --change-shell) change_shell=1;;
        --help|-h) usage; exit 0;; *) die "Opción desconocida: $arg";;
    esac
done
if [[ "$mode" == check ]]; then exec bash "$DOTFILES_ROOT/scripts/doctor.sh"; fi
(( EUID != 0 )) || [[ "${DOTFILES_ALLOW_ROOT:-0}" == 1 ]] || die 'Ejecuta como usuario, sin sudo.'
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
[[ "$HOME" == /* && "$HOME" != / && "$config_dir" == /* && "$config_dir" != / ]] || die 'Rutas de usuario inválidas.'
sources=("$DOTFILES_ROOT/zsh/.zshrc" "$DOTFILES_ROOT/nvim" "$DOTFILES_ROOT/kitty")
destinations=("$HOME/.zshrc" "$config_dir/nvim" "$config_dir/kitty")
# Preflight completo antes del primer reemplazo.
for i in "${!sources[@]}"; do
    src="$(realpath -e -- "${sources[i]}")" || die "Origen inexistente: ${sources[i]}"
    dst="${destinations[i]}"
    parent="$(realpath -m -- "$(dirname -- "$dst")")"
    physical_dst="$parent/$(basename -- "$dst")"
    [[ "$src" != "$physical_dst" && "$DOTFILES_ROOT" != "$physical_dst" && "$DOTFILES_ROOT" != "$physical_dst/"* ]] || die "El destino contiene el repositorio: $dst"
    [[ "$physical_dst" != / && "$physical_dst" != "$HOME" ]] || die "Destino protegido: $dst"
done
safe_link() {
    local src="$1" dst="$2" allowed=0 item
    for item in "${destinations[@]}"; do [[ "$dst" != "$item" ]] || allowed=1; done
    (( allowed )) || die "Destino fuera del manifiesto: $dst"
    [[ -e "$src" ]] || die "No existe: $src"
    if [[ -L "$dst" && "$(readlink -f -- "$dst" || true)" == "$(realpath -e -- "$src")" ]]; then
        log "Enlace correcto: $dst"; return
    fi
    mkdir -p -- "$(dirname -- "$dst")"
    if [[ -e "$dst" || -L "$dst" ]]; then
        log "Reemplazando: $dst"
        if [[ -L "$dst" || ! -d "$dst" ]]; then rm -f -- "$dst"; else rm -rf --one-file-system -- "$dst"; fi
    fi
    ln -sT -- "$src" "$dst"
}
for i in "${!sources[@]}"; do safe_link "${sources[i]}" "${destinations[i]}"; done
[[ "$mode" != links ]] || { log 'Enlaces listos.'; exit 0; }
for module in common git zsh kitty nvim vhri fonts; do
    log "Instalando/comprobando $module"
    bash "$DOTFILES_ROOT/install/$module.sh"
done
if (( with_riscv )); then bash "$DOTFILES_ROOT/install/riscv.sh"; fi
if (( with_docker )); then bash "$DOTFILES_ROOT/install/docker.sh"; fi
if (( with_gnome )); then bash "$DOTFILES_ROOT/install/desktop.sh"; fi
bash "$DOTFILES_ROOT/install/nvim-tools.sh"
if (( change_shell )); then chsh -s "$(command -v zsh)"; fi
bash "$DOTFILES_ROOT/scripts/doctor.sh"
log 'Instalación terminada. Abre una terminal nueva.'
