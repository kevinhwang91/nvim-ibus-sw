#!/usr/bin/env sh

get_input() {
    ibus engine
}

set_input() {
    local pre_input=$(ibus engine)
    if [[ $pre_input != $1 ]]; then
        ibus engine $1
    fi
    echo $pre_input
}

init() {
    echo 0
}

$@
