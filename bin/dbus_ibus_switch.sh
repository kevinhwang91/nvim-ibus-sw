#!/usr/bin/env sh

get_input() {
    dbus-send --session --type=method_call --print-reply=literal --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:"imports.ui.status.keyboard.getInputSourceManager().currentSource.index" | sed -n -E "s/^\s+([0-9]+).*/\1/p"
}

set_input() {
    local pre_input=$(get_input)
    if [[ $pre_input != $1 ]]; then
        dbus-send --session --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:"imports.ui.status.keyboard.getInputSourceManager().inputSources[$1].activate()"
    fi
    echo $pre_input
}

init() {
    local size=$(dbus-send --session --type=method_call --print-reply=literal --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:"Object.keys(imports.ui.status.keyboard.getInputSourceManager().inputSources).length" | sed -n -E "s/^\s+([0-9]+).*/\1/p")
    if (( $size < 2 )); then
        echo 1
    else
        echo 0
    fi
}

$@
