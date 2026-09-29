# ============================================================
# Zsh Functions
# ============================================================
#
# GUTS Dotfiles
#
# Este archivo contiene:
#   - Utilidades internas
#   - Construcción del prompt
#   - Estado Git del prompt
#   - Funciones Git
#   - Funciones GitHub CLI
#   - Selectores interactivos con fzf
#   - Herramientas FPGA / Xilinx
#
# ============================================================


# ============================================================
# Internal Utilities
# ============================================================

function dotfiles_need() {
    command -v "$1" >/dev/null || {
        print -u2 -- "Falta el comando: $1"
        return 1
    }
}

# ============================================================
# Prompt
# ============================================================

function dotfiles_precmd() {
    local tint="red"
    local ghost="󱙜"
    local label="$PWD"
    local width="${COLUMNS:-80}"

    # --------------------------------------------------------
    # Current Directory
    # --------------------------------------------------------

    if [[ "$PWD" == "$HOME" ]]; then
        tint="blue"
        ghost="󱙝"
        label="~"

    elif [[ "$PWD" == "$HOME/"* ]]; then
        label="~/${PWD#$HOME/}"
    fi


    # --------------------------------------------------------
    # Path Length
    # --------------------------------------------------------

    local maxpath=$(( width > 35 ? width - 30 : 10 ))

    if (( ${#label} > maxpath )); then
        label="…${label[-maxpath,-1]}"
    fi


    # --------------------------------------------------------
    # Escape Prompt Characters
    # --------------------------------------------------------

    # Evita interpretar '%' contenido en nombres de directorios.
    label=${label//\%/%%}

    local user_label=${USER//\%/%%}


    # --------------------------------------------------------
    # Prompt Width
    # --------------------------------------------------------

    local left="╭──[ $ghost ][ $label ]"
    local right="[ $user_label ]──╮"

    local pad=$(( width - ${#left} - ${#right} - 3 ))

    (( pad >= 0 )) || pad=0


    # --------------------------------------------------------
    # Prompt Composition
    # --------------------------------------------------------

    DF_PROMPT_TOP="%B%F{$tint}╭──%f%b%F{magenta}[ $ghost ]%f%F{cyan}[ $label ]%f %F{$tint}${(l:$pad::-:)}%f %F{magenta}[ $user_label ]%f%F{$tint}──╮%f"

    DF_PROMPT_BOTTOM="%B%F{$tint}╰──%f%b%F{magenta}➤  %f"


    # --------------------------------------------------------
    # Git Status
    # --------------------------------------------------------

    dotfiles_git_refresh

    return 0
}

# ============================================================
# Git Prompt
# ============================================================

function dotfiles_git_refresh() {
    DF_GIT_PROMPT=""

    # No hacer nada si Git no está disponible.
    (( $+commands[git] )) || return 0

    # --------------------------------------------------------
    # State
    # --------------------------------------------------------

    local report
    local line
    local xy

    local branch=""
    local flags=""

    local ahead=0
    local behind=0
    local stashes=0

    local added=0
    local modified=0
    local deleted=0
    local renamed=0
    local conflict=0
    local untracked=0

    # --------------------------------------------------------
    # Repository Status
    # --------------------------------------------------------

    # Una sola consulta local.
    #
    # No realiza:
    #   - fetch
    #   - pull
    #   - llamadas a GitHub
    #
    # GIT_OPTIONAL_LOCKS evita bloquear innecesariamente el repo.

    report=$(
        GIT_OPTIONAL_LOCKS=0 \
        command git status \
            --porcelain=v2 \
            --branch \
            --show-stash \
            2>/dev/null
    ) || return 0

    # --------------------------------------------------------
    # Parse Git Status
    # --------------------------------------------------------

    for line in "${(@f)report}"; do

        case "$line" in

            '# branch.head '*)
                branch=${line#\# branch.head }
                ;;

            '# branch.oid '*)
                if [[ "$branch" == "(detached)" ]]; then
                    branch="@${${line#\# branch.oid }[1,8]}"
                fi
                ;;

            '# branch.ab '*)
                local counts=(${=line})

                ahead=${counts[3]#+}
                behind=${counts[4]#-}
                ;;

            '# stash '*)
                stashes=${line#\# stash }
                ;;

            '? '*)
                untracked=1
                ;;

            'u '*)
                conflict=1
                ;;

            [12]' '*)
                xy=${line[3,4]}

                [[ "$xy" == *A* ]] && added=1
                [[ "$xy" == *M* ]] && modified=1
                [[ "$xy" == *D* ]] && deleted=1
                [[ "$xy" == *R* ]] && renamed=1
                ;;

        esac

    done


    # --------------------------------------------------------
    # Detached HEAD
    # --------------------------------------------------------

    if [[ "$branch" == "(detached)" ]]; then
        branch="@$(command git rev-parse --short HEAD 2>/dev/null)"
    fi


    # --------------------------------------------------------
    # Prompt Safety
    # --------------------------------------------------------

    branch=${branch//\%/%%}


    # --------------------------------------------------------
    # Working Tree Flags
    # --------------------------------------------------------

    (( added )) && flags+="$ZSH_THEME_GIT_PROMPT_ADDED"

    (( modified )) && flags+="$ZSH_THEME_GIT_PROMPT_MODIFIED"

    (( deleted )) && flags+="$ZSH_THEME_GIT_PROMPT_DELETED"

    (( renamed )) && flags+="$ZSH_THEME_GIT_PROMPT_RENAMED"

    (( conflict )) && flags+="$ZSH_THEME_GIT_PROMPT_UNMERGED"

    (( untracked )) && flags+="$ZSH_THEME_GIT_PROMPT_UNTRACKED"


    # --------------------------------------------------------
    # Remote / Stash State
    # --------------------------------------------------------

    (( ahead )) && flags+=" %F{green}⇡$ahead%f"

    (( behind )) && flags+=" %F{red}⇣$behind%f"

    (( stashes )) && flags+=" %F{yellow}󰏗 $stashes%f"


    # --------------------------------------------------------
    # Final Git Prompt
    # --------------------------------------------------------

    DF_GIT_PROMPT="%F{magenta}[%f \
%F{cyan}%f\
${ZSH_THEME_GIT_PROMPT_PREFIX}\
$branch\
${ZSH_THEME_GIT_PROMPT_SUFFIX}\
$flags \
%F{magenta}]%f\
%F{red}──╯%f"

    return 0
}


# ============================================================
# Git Utilities
# ============================================================

# ------------------------------------------------------------
# Current Branch
# ------------------------------------------------------------

function git_branch_name() {
    command git branch --show-current 2>/dev/null
}


# ------------------------------------------------------------
# Commit
# ------------------------------------------------------------

function gac() {
    (( $# )) || {
        print -u2 'Uso: gac "mensaje"'
        return 1
    }

    command git add --all &&
        command git commit -m "$*"
}


function gacp() {
    gac "$@" &&
        command git push
}


# ------------------------------------------------------------
# Branches
# ------------------------------------------------------------

function gnew() {
    (( $# == 1 )) || {
        print -u2 "Uso: gnew rama"
        return 1
    }

    command git switch -c "$1"
}


function gdel() {
    (( $# == 1 )) || {
        print -u2 "Uso: gdel rama"
        return 1
    }

    command git branch -d -- "$1"
}


# ------------------------------------------------------------
# Repository Root
# ------------------------------------------------------------

function groot() {
    local root

    root=$(command git rev-parse --show-toplevel) || return

    cd -- "$root"
}


# ------------------------------------------------------------
# Synchronization
# ------------------------------------------------------------

function gsync() {
    local upstream

    upstream=$(
        command git rev-parse \
            --abbrev-ref \
            '@{upstream}' \
            2>/dev/null
    ) || {
        print -u2 "Esta rama no tiene upstream."
        return 1
    }

    print -r -- "Sincronizando con $upstream"

    command git fetch --prune &&
        command git pull --rebase
}


# ------------------------------------------------------------
# Repository Information
# ------------------------------------------------------------

function ginfo() {
    command git rev-parse --show-toplevel &&
        command git remote -v &&
        command git status --short --branch
}


# ------------------------------------------------------------
# Remove Merged Branches
# ------------------------------------------------------------

function gcleanmerged() {
    local current
    local branch
    local merged

    current=$(command git branch --show-current) || return

    [[ -n "$current" ]] || {
        print -u2 "HEAD separado; selecciona una rama."
        return 1
    }

    merged=$(
        command git for-each-ref \
            --merged=HEAD \
            --format='%(refname:short)' \
            refs/heads
    ) || return

    for branch in "${(@f)merged}"; do

        case "$branch" in
            ""|main|master|develop|"$current")
                continue
                ;;
        esac

        command git branch -d -- "$branch" || return

    done
}


# ============================================================
# GitHub CLI
# ============================================================

function ghrepo() {
    dotfiles_need gh || return

    command gh repo view --web "$@"
}


function ghbranch() {
    dotfiles_need gh || return

    local branch

    branch=$(command git branch --show-current) || return

    [[ -n "$branch" ]] || {
        print -u2 "HEAD separado."
        return 1
    }

    command gh browse --branch "$branch"
}


function ghpr() {
    dotfiles_need gh || return

    command gh pr view --web "$@"
}


function ghprc() {
    dotfiles_need gh || return

    command gh pr create "$@"
}


function ghinfo() {
    dotfiles_need gh || return

    command gh repo view \
        --json nameWithOwner,description,url,defaultBranchRef \
        --template 'Repository: {{.nameWithOwner}}{{"\n"}}Branch: {{.defaultBranchRef.name}}{{"\n"}}URL: {{.url}}{{"\n"}}{{.description}}{{"\n"}}'
}


# ============================================================
# Interactive Git Selectors
# ============================================================

# ------------------------------------------------------------
# Branch Selector
# ------------------------------------------------------------

function dotfiles_git_pick_branch() {
    dotfiles_need fzf || return

    local branch

    branch=$(
        command git for-each-ref \
            --sort=-committerdate \
            --format='%(refname:short)' \
            refs/heads |
            fzf --prompt='Rama > '
    ) || return

    [[ -n "$branch" ]] &&
        command git switch -- "$branch"
}


# ------------------------------------------------------------
# Commit Selector
# ------------------------------------------------------------

function dotfiles_git_pick_commit() {
    dotfiles_need fzf || return

    local line

    line=$(
        command git log --oneline -200 |
            fzf --prompt='Commit > '
    ) || return

    [[ -n "$line" ]] &&
        command git show "${line%% *}"
}


# ============================================================
# Interactive GitHub Selectors
# ============================================================

function dotfiles_gh_pick_repo() {
    dotfiles_need gh || return
    dotfiles_need fzf || return

    local repo

    repo=$(
        command gh repo list \
            --limit 100 \
            --json nameWithOwner \
            --jq '.[].nameWithOwner' |
            fzf --prompt='GitHub > '
    ) || return

    [[ -n "$repo" ]] &&
        command gh repo view "$repo" --web
}


# ============================================================
# Xilinx ISE
# ============================================================

function ise() {
    local settings="${XILINX_SETTINGS:-/opt/Xilinx/14.7/ISE_DS/settings64.sh}"

    [[ -r "$settings" ]] || {
        print -u2 -- "No existe: $settings"
        return 1
    }

    bash -c \
        'source "$1" && exec ise' \
        _ \
        "$settings"
}


# ============================================================
# Digilent / Nexys 3
# ============================================================

function digilent() {
    (( $# == 1 )) || {
        print -u2 "Uso: digilent archivo.bit"
        return 1
    }

    dotfiles_need djtgcfg || return

    local bit_file="${1:A}"

    [[ -f "$bit_file" ]] || {
        print -u2 -- "No existe: $bit_file"
        return 1
    }

    command djtgcfg init \
        -d Nexys3 &&

        command djtgcfg prog \
            -d Nexys3 \
            -i 0 \
            -f "$bit_file"
}
