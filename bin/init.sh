#!/usr/bin/env bash

if [[ ! -x $(command -v ibus) || $XDG_SESSION_TYPE == tty || -z $XDG_CURRENT_DESKTOP ]]; then
    echo -n "{'ret_code': 1}"
    exit 1
fi

work_dir=$(cd -P "$(dirname "$0")" && pwd -P)
if [[ $XDG_CURRENT_DESKTOP == GNOME && -x $(command -v gnome-shell) && $(
    gnome-shell --version | awk
    '{match($3, /[0-9]+\.[0-9]+/, m);exit m[0]<41}'
) ]]; then
    itype='dbus'
    bin="$work_dir/dbus_ibus_switch.sh"
else
    itype='engine'
    bin="$work_dir/ibus_engine_switch.sh"
fi

current_input=$($bin get_input)
ret_code=$($bin init)
echo -n "{'itype': '$itype', 'bin': '$bin', 'current_input': '$current_input', 'ret_code': '$ret_code'}"
