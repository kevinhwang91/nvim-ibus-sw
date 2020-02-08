let s:input_trigger=1
let s:init_bin = expand('<sfile>:h:h') . '/bin/init.sh'

function is#init(ret_dict) abort
    let d = a:ret_dict
    if !has_key(d, 'itype') || empty(d.itype) ||
                \ !has_key(d, 'current_input') || empty(d.current_input) ||
                \ !has_key(d, 'bin') || empty(d.bin) ||
                \ !has_key(d, 'ret_code') || empty(d.ret_code)
        " no need to initialize ibus-sw, such as size of input method < 2
        return
    endif
    let s:bin = d.bin
    let s:normal_cache = d.current_input
    let s:insert_cache = d.current_input
    augroup ibus_sw
        au!
        autocmd InsertLeave * if s:input_trigger | call is#restore_normal() | endif
        autocmd InsertEnter * if s:input_trigger | call is#restore_insert() | endif
        if d.itype == 'engine'
            autocmd FocusGained * if s:insert_cache != s:normal_cache && mode() == 'n' |
                        \ sleep 200m | call is#restore_normal() | endif
        endif
    augroup END
endfunction

function is#restore_normal() abort
    if exists('*jobstart')
        call jobstart([s:bin, 'set_input', s:normal_cache], {
                    \ 'on_stdout': {j, d, e -> execute('let s:insert_cache = d[0]')},
                    \ 'stdout_buffered': 1
                    \ })
    elseif exists('*job_start')
        call job_start([s:bin, 'set_input', s:normal_cache], {
                    \ 'out_cb': {c, d -> execute('let s:insert_cache = d')}
                    \ })
    else
        let s:insert_cache = system(s:bin . ' set_input ' . s:normal_cache)
    endif
endfunction

function is#restore_insert() abort
    if exists('*jobstart')
        call jobstart([s:bin, 'set_input', s:insert_cache], {
                    \ 'on_stdout': {j, d, e -> execute('let s:normal_cache = d[0]')},
                    \ 'stdout_buffered': 1
                    \ })
    elseif exists('*job_start')
        call job_start([s:bin, 'set_input', s:insert_cache], {
                    \ 'out_cb': {c, d -> execute('let s:normal_cache = d')}
                    \ })
    else
        let s:normal_cache = system(s:bin . ' set_input ' . s:insert_cache)
    endif
endfunction

function is#lazy_load() abort
    if exists('*jobstart')
        call jobstart(s:init_bin, {
                    \ 'on_stdout': {j, d, e -> call(function('is#init'), [eval(d[0])])},
                    \ 'stdout_buffered': 1
                    \ })
    elseif exists('*job_start')
        call job_start(s:init_bin, {
                    \ 'out_cb': {c, d -> call(function('is#init'), [eval(d)])}
                    \ })
    else
        let s:ret_dict = eval(system(s:init_bin)[:-2])
        call init(s:ret_dict)
    endif
endfunction

function is#input_trigger_enable()
    let s:input_trigger=1
endfunction

function is#input_trigger_disable()
    let s:input_trigger=0
endfunction
