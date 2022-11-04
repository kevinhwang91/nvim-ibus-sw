#!/usr/bin/env bash

get_input() {
    dbus-send --session --type=method_call --print-reply=literal --dest=org.gnome.Shell /org/gnome/Shell/Extensions/IbusSwitcher org.gnome.Shell.Extensions.IbusSwitcher.GetCurrentSource
}

set_input() {
    dbus-send --session --type=method_call --print-reply=literal --dest=org.gnome.Shell /org/gnome/Shell/Extensions/IbusSwitcher org.gnome.Shell.Extensions.IbusSwitcher.SwitchSource uint32:$1 string:"$2"
}

init() {
    dbus-send --session --type=method_call --print-reply=literal --dest=org.gnome.Shell /org/gnome/Shell/Extensions/IbusSwitcher org.gnome.Shell.Extensions.IbusSwitcher.GetSourceSize
}

"$@"
