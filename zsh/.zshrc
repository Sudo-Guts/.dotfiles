# GUTS: entorno, carga y composición del prompt.
# :A resuelve el symlink; funciona aunque el repo no esté en ~/.dotfiles.
export DOTFILES="${${(%):-%x}:A:h:h}"
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export RISCV="${RISCV:-/opt/riscv}"
typeset -U path PATH
dotfiles_mason_bin="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"
path=("$HOME/.local/bin" "$HOME/.local/kitty.app/bin" "$RISCV/bin"
      "$HOME/.local/opt/riscv/bin"
      "$HOME/.local/xPacks/@xpack-dev-tools/riscv-none-elf-gcc/latest/bin"
      "${(@)path:#"$dotfiles_mason_bin"}" "$dotfiles_mason_bin")
unset dotfiles_mason_bin
export PATH
export EDITOR=nvim VISUAL=nvim
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p -- "${HISTFILE:h}"
HISTSIZE=20000 SAVEHIST=20000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY INTERACTIVE_COMMENTS
setopt PROMPT_SUBST
unsetopt FLOW_CONTROL
zstyle ':omz:update' mode disabled
zstyle ':omz:alpha:lib:git' async-prompt no
ZSH_THEME=""
ENABLE_CORRECTION="true"
plugins=()
# highlighter se carga al final, después de los widgets propios.
for plugin in git zsh-interactive-cd zsh-autosuggestions zsh-history-substring-search; do
    if [[ -f "${ZSH_CUSTOM:-$ZSH/custom}/plugins/$plugin/$plugin.plugin.zsh" || -f "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]]; then
        plugins+=("$plugin")
    fi
done
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
    if [[ -z ${_GUTS_OMZ_LOADED:-} ]]; then
        source "$ZSH/oh-my-zsh.sh"
        typeset -g _GUTS_OMZ_LOADED=1
    fi
else
    autoload -Uz compinit
    compinit -d "${HISTFILE:h}/zcompdump"
fi
# Evitar expansión de aliases de OMZ al definir funciones y tras recargar .zshrc.
for name in gac gacp gnew gdel groot gsync ginfo gcleanmerged ghrepo ghbranch ghpr ghprc ghinfo ise digilent; do
    (( $+aliases[$name] )) && unalias "$name"
done
for part in function git aliases; do
    [[ ! -r "$DOTFILES/zsh/$part.zsh" ]] || source "$DOTFILES/zsh/$part.zsh"
done
autoload -Uz add-zsh-hook
add-zsh-hook -d precmd dotfiles_precmd 2>/dev/null
add-zsh-hook precmd dotfiles_precmd
typeset -U precmd_functions preexec_functions chpwd_functions
bindkey -e
if (( $+widgets[history-substring-search-up] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi
PROMPT='${DF_PROMPT_TOP}
${DF_PROMPT_BOTTOM}'
RPROMPT='${DF_GIT_PROMPT}'
local_highlight="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [[ -r "$local_highlight" && -z ${ZSH_HIGHLIGHT_VERSION:-} ]]; then source "$local_highlight"; fi
unset local_highlight part plugin name
dotfiles_precmd
