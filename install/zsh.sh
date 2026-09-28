#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
apt_install zsh fzf git
zsh_root="${ZSH:-$HOME/.oh-my-zsh}"
sync_repo https://github.com/ohmyzsh/ohmyzsh.git "$zsh_root"
plugin_root="${ZSH_CUSTOM:-$zsh_root/custom}/plugins"
for plugin in zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting; do
    sync_repo "https://github.com/zsh-users/$plugin.git" "$plugin_root/$plugin"
done
log 'Zsh listo; fzf usa apt y bootstrap administra .zshrc.'
