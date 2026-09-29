# ============================================================
# Zsh Configuration
# ============================================================
#
# GUTS Dotfiles
#
# Este archivo se encarga únicamente de:
#   - Variables de entorno
#   - PATH
#   - Historial
#   - Oh My Zsh
#   - Carga de módulos propios
#   - Hooks y keybindings
#   - Prompt
#
# ============================================================


# ============================================================
# Environment
# ============================================================

# Resuelve la ubicación real del repositorio incluso cuando
# ~/.zshrc es un enlace simbólico.
export DOTFILES="${${(%):-%x}:A:h:h}"

export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export RISCV="${RISCV:-/opt/riscv}"

export EDITOR="nvim"
export VISUAL="nvim"


# ============================================================
# PATH
# ============================================================

# Evita entradas duplicadas automáticamente.
typeset -U path PATH

MASON_BIN="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"

path=(
    "$HOME/.local/bin"
    "$HOME/.local/kitty.app/bin"

    "$RISCV/bin"
    "$HOME/.local/opt/riscv/bin"
    "$HOME/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/latest/bin"

    # Conservar las rutas existentes, excepto Mason.
    "${(@)path:#"$MASON_BIN"}"

    # Mason queda al final para dar prioridad a las herramientas
    # instaladas por el sistema.
    "$MASON_BIN"
)

export PATH

unset MASON_BIN


# ============================================================
# History
# ============================================================

HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"

[[ -d "${HISTFILE:h}" ]] || mkdir -p -- "${HISTFILE:h}"

HISTSIZE=20000
SAVEHIST=20000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INTERACTIVE_COMMENTS


# ============================================================
# Shell Options
# ============================================================

setopt PROMPT_SUBST

# Ctrl+S / Ctrl+Q no controlan el flujo del terminal.
unsetopt FLOW_CONTROL


# ============================================================
# Oh My Zsh
# ============================================================

ZSH_THEME=""

# Deshabilitar actualización automática.
zstyle ':omz:update' mode disabled

# Nuestro prompt administra Git por su cuenta.
zstyle ':omz:alpha:lib:git' async-prompt no

ENABLE_CORRECTION="true"


# ============================================================
# Plugins
# ============================================================

plugins=()

for plugin in \
    git \
    zsh-interactive-cd \
    zsh-autosuggestions \
    zsh-history-substring-search
do
    plugin_dir="${ZSH_CUSTOM:-$ZSH/custom}/plugins/$plugin"
    builtin_plugin_dir="$ZSH/plugins/$plugin"

    if [[ -f "$plugin_dir/$plugin.plugin.zsh" ]] ||
       [[ -f "$builtin_plugin_dir/$plugin.plugin.zsh" ]]; then
        plugins+=("$plugin")
    fi
done

unset plugin_dir builtin_plugin_dir


# ============================================================
# Load Oh My Zsh
# ============================================================

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then

    # Evita cargar Oh My Zsh dos veces al ejecutar:
    #
    #   source ~/.zshrc
    #
    if [[ -z "${_GUTS_OMZ_LOADED:-}" ]]; then
        source "$ZSH/oh-my-zsh.sh"
        typeset -g _GUTS_OMZ_LOADED=1
    fi

else

    # Fallback mínimo si Oh My Zsh no está disponible.
    autoload -Uz compinit
    compinit -d "${HISTFILE:h}/zcompdump"

fi


# ============================================================
# Remove Conflicting Oh My Zsh Aliases
# ============================================================

# Algunas funciones propias utilizan nombres que Oh My Zsh
# también puede registrar como aliases.
#
# Se eliminan antes de cargar function.zsh para evitar expansión
# accidental durante la definición de funciones.

for name in \
    gac \
    gacp \
    gnew \
    gdel \
    groot \
    gsync \
    ginfo \
    gcleanmerged \
    ghrepo \
    ghbranch \
    ghpr \
    ghprc \
    ghinfo \
    ise \
    digilent
do
    (( $+aliases[$name] )) && unalias "$name"
done


# ============================================================
# Dotfiles Modules
# ============================================================

for module in \
    function \
    git \
    aliases
do
    config_file="$DOTFILES/zsh/$module.zsh"

    [[ -r "$config_file" ]] && source "$config_file"
done

unset config_file module


# ============================================================
# Hooks
# ============================================================

autoload -Uz add-zsh-hook

# Evita duplicar el hook si ~/.zshrc se recarga.
add-zsh-hook -d precmd dotfiles_precmd 2>/dev/null
add-zsh-hook precmd dotfiles_precmd

typeset -U \
    precmd_functions \
    preexec_functions \
    chpwd_functions


# ============================================================
# Keybindings
# ============================================================

bindkey -e

if (( $+widgets[history-substring-search-up] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi


# ============================================================
# Prompt
# ============================================================

PROMPT='${DF_PROMPT_TOP}
${DF_PROMPT_BOTTOM}'

RPROMPT='${DF_GIT_PROMPT}'


# ============================================================
# Syntax Highlighting
# ============================================================

# zsh-syntax-highlighting debe cargarse al final para evitar
# conflictos con widgets definidos previamente.

SYNTAX_HIGHLIGHT_FILE="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if [[ -r "$SYNTAX_HIGHLIGHT_FILE" ]] &&
   [[ -z "${ZSH_HIGHLIGHT_VERSION:-}" ]]; then

    source "$SYNTAX_HIGHLIGHT_FILE"

fi

unset SYNTAX_HIGHLIGHT_FILE


# ============================================================
# Initial Prompt State
# ============================================================

# Actualiza las variables del prompt inmediatamente, también
# cuando ~/.zshrc se recarga manualmente.
dotfiles_precmd


# ============================================================
# Cleanup
# ============================================================

unset plugin name
