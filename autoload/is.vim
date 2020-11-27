let s:input_trigger = 1
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
    let s:n_cache = d.current_input
    let s:i_cache = d.current_input
    " change input method using dbus will trigger FocusGained event
    let s:focus_set = d.itype == 'dbus' && (has('nvim') || has('gui_running'))
    augroup IbusSw
        autocmd!
        if s:focus_set
            autocmd FocusGained * call <SID>update_input_cache()
        endif
        autocmd InsertEnter * if s:input_trigger | call <SID>restore_input_method('i') | endif
        autocmd InsertLeave * if s:input_trigger | call <SID>restore_input_method('n') | endif
    augroup END
endfunction

function s:update_input_cache() abort
    let mode = mode() == 'n' ? 'n' : 'i'
    if exists('*jobstart')
        call jobstart([s:bin, 'get_input'], {
                    \ 'on_stdout': {j, d, e -> execute('let s:' . mode . '_cache = d[0]')},
                    \ 'stdout_buffered': 1
                    \ })
    else
        call job_start([s:bin, 'get_input'], {
                    \ 'out_cb': {c, d -> execute('let s:' . mode . '_cache = d')}
                    \ })
    endif
endfunction

function s:restore_input_method(mode) abort
    let cache = a:mode == 'n' ? s:n_cache : s:i_cache
    if s:focus_set
        if s:i_cache != s:n_cache
            if exists('*jobstart')
                call jobstart([s:bin, 'set_input', cache])
            else
                call job_start([s:bin, 'set_input', cache])
            endif
        endif
    else
        let r_mode = a:mode == 'n' ? 'i' : 'n'
        if exists('*jobstart')
            call jobstart([s:bin, 'set_input', cache], {
                        \ 'on_stdout': {j, d, e -> execute('let s:' . r_mode . '_cache = d[0]')},
                        \ 'stdout_buffered': 1
                        \ })
        else
            call job_start([s:bin, 'set_input', cache], {
                        \ 'out_cb': {c, d -> execute('let s:' . r_mode . '_cache = d')}
                        \ })
        endif
    endif
endfunction

function! is#lazy_load() abort
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
        echoerr 'job start is not supported, fail to initialize.'
    endif
endfunction

function! is#input_trigger_enable()
    let s:input_trigger = 1
endfunction

function! is#input_trigger_disable()
    let s:input_trigger = 0
endfunction
