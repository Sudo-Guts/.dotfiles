#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
apt_install ghdl gtkwave iverilog
log 'Simuladores HDL listos. Verible y VHDL LS se administran con Mason.'
