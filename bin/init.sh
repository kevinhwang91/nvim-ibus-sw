#!/usr/bin/env sh

work_dir=$(cd -P "$(dirname $0)" && pwd -P)

if [[ $DESKTOP_SESSION == "gnome" && -x $(command -v dbus-send) ]]; then
    itype="dbus"
    bin="$work_dir/dbus_ibus_switch.sh"
else
    itype="engine"
    bin="$work_dir/ibus_engine_switch.sh"
fi

current_input=$($bin get_input)
ret_code=$($bin init)
echo "{'itype': '$itype', 'bin': '$bin', 'current_input': '$current_input', 'ret_code': '$ret_code'}"
