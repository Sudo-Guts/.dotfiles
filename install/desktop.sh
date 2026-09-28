#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"
[[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] || { log 'No hay sesión GNOME; omitido.'; exit 0; }
require_command gsettings
require_command kitty
python3 - <<'PYTHON'
import ast, shlex, shutil, subprocess
schema='org.gnome.settings-daemon.plugins.media-keys'
path='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guts-kitty/'
raw=subprocess.check_output(['gsettings','get',schema,'custom-keybindings'],text=True).strip()
paths=ast.literal_eval(raw.removeprefix('@as '))
if path not in paths: paths.append(path)
subprocess.run(['gsettings','set',schema,'custom-keybindings',repr(paths)],check=True)
for key,value in [('name','Kitty'),('command',shlex.quote(shutil.which('kitty'))),('binding','<Control><Alt>t')]:
 subprocess.run(['gsettings','set',schema+'.custom-keybinding:'+path,key,value],check=True)
PYTHON
