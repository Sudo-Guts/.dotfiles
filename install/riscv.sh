#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
# No borra /opt/riscv ni altera .zshrc. El modo fuente es explícito.
if [[ "${1:-}" != --source ]]; then
    [[ $# == 0 ]] || die 'Uso: riscv.sh [--source]'
    apt_install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf gdb-multiarch qemu-system-misc
    log 'Toolchain del sistema lista; usa -march=rv32i -mabi=ilp32 para tu CPU.'
    exit 0
fi
apt_install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev \
    libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils \
    bc zlib1g-dev libexpat1-dev ninja-build git cmake device-tree-compiler \
    libboost-regex-dev libboost-system-dev
build_root="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/riscv"
prefix="${RISCV_BUILD_PREFIX:-$HOME/.local/opt/riscv}"
mkdir -p "$build_root" "$prefix"
export PATH="$prefix/bin:$PATH"
# No reinstala componentes completos; borra los marcadores solo para reconstruir.
if [[ ! -f "$prefix/.toolchain-complete" ]]; then
    sync_repo https://github.com/riscv-collab/riscv-gnu-toolchain.git "$build_root/toolchain"
    mkdir -p "$build_root/toolchain-build"
    (cd "$build_root/toolchain-build" || exit
     "$build_root/toolchain/configure" --prefix="$prefix" --enable-multilib \
         --with-multilib-generator='rv32i-ilp32--;rv64gc-lp64d--'
     make -j"${DOTFILES_JOBS:-2}")
    touch "$prefix/.toolchain-complete"
fi
if [[ ! -f "$prefix/.spike-complete" ]]; then
    sync_repo https://github.com/riscv-software-src/riscv-isa-sim.git "$build_root/spike"
    mkdir -p "$build_root/spike-build"
    (cd "$build_root/spike-build" || exit; "$build_root/spike/configure" --prefix="$prefix"; make -j"${DOTFILES_JOBS:-2}"; make install)
    touch "$prefix/.spike-complete"
fi
if [[ ! -f "$prefix/.pk-complete" ]]; then
    sync_repo https://github.com/riscv-software-src/riscv-pk.git "$build_root/pk"
    mkdir -p "$build_root/pk-build"
    (cd "$build_root/pk-build" || exit
     "$build_root/pk/configure" --prefix="$prefix" --host=riscv64-unknown-elf --with-arch=rv64gc --with-abi=lp64d
     make -j"${DOTFILES_JOBS:-2}"; make install)
    touch "$prefix/.pk-complete"
fi
log "Toolchain multilib + Spike + pk RV64 instalados en $prefix. pk no es el firmware de tu CPU RV32I."
