#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
apt_install git gh
git config --global push.autoSetupRemote true
git config --global fetch.prune true
git config --global pull.rebase true
git config --global rerere.enabled true
git config --global color.ui auto
git config --global column.ui auto
git config --global branch.sort -committerdate
git config --global tag.sort version:refname
log 'Git configurado; se conserva identidad y credenciales.'
