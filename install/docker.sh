#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
source /etc/os-release
case "$ID" in ubuntu|debian) distro="$ID";; *) die 'Docker: se requiere Ubuntu o Debian oficial.';; esac
apt_install ca-certificates curl
work="$(mktemp -d)"; trap 'rm -rf -- "$work"' EXIT
download "https://download.docker.com/linux/$distro/gpg" "$work/docker.asc"
as_root install -d -m755 /etc/apt/keyrings
as_root install -m644 "$work/docker.asc" /etc/apt/keyrings/docker.asc
printf 'deb [arch=%s signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/%s %s stable\n' \
    "$(dpkg --print-architecture)" "$distro" "$VERSION_CODENAME" > "$work/docker.list"
as_root install -m644 "$work/docker.list" /etc/apt/sources.list.d/docker.list
apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
if [[ -d /run/systemd/system ]]; then as_root systemctl enable --now docker; fi
docker --version
docker compose version
log 'Usa sudo docker; la pertenencia al grupo docker no se modifica.'
