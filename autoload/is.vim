let s:input_trigger=1
let s:init_bin = expand("<sfile>:h:h") . "/bin/init.sh"

function! is#init(ret_dict)
    let s:ret_code = a:ret_dict["ret_code"]
    if s:ret_code
        " no need to initialize ibus-sw, such as size of input method < 2
        return
    endif
    let s:itype = a:ret_dict["itype"]
    let s:bin = a:ret_dict["bin"]
    let s:current_input = a:ret_dict["current_input"]
    let s:normal_cache = s:current_input
    let s:insert_cache = s:current_input
    augroup ibus_sw
        au!
        autocmd InsertLeave * if s:input_trigger | :call is#restore_normal()
        autocmd InsertEnter * if s:input_trigger | :call is#restore_insert()
        if s:itype == 'engine'
            autocmd FocusGained * if s:insert_cache != s:normal_cache | if mode()!='i'| sleep 200m | :call is#restore_normal()
        endif
    augroup END
endfunction

" neovim asynchronous callback function
" ======================================================
function! is#nvim_init(job_id, data, event)
    let s:ret_dict = eval(a:data[0])
    call is#init(s:ret_dict)
endfunction

function! is#nvim_set_insert_cache(job_id, data, event)
    let s:insert_cache = a:data[0]
endfunction

function! is#nvim_set_normal_cache(job_id, data, event)
    let s:normal_cache = a:data[0]
endfunction
" ======================================================

" vim asynchronous callback function
" ======================================================
function! is#vim_init(channel, data)
    let s:ret_dict = eval(a:data)
    call is#init(s:ret_dict)
endfunction

function! is#vim_set_insert_cache(channel, data)
    let s:insert_cache = a:data
endfunction

function! is#vim_set_normal_cache(channel, data)
    let s:normal_cache = a:data
endfunction
" ======================================================

function! is#restore_normal()
    if exists('*jobstart')
        call jobstart([s:bin, 'set_input', s:normal_cache], {'on_stdout': function('is#nvim_set_insert_cache'), 'stdout_buffered': 1})
    elseif exists('*job_start')
        call job_start([s:bin, 'set_input', s:normal_cache], {'out_cb': function('is#vim_set_insert_cache')})
    else
        let s:insert_cache = system(s:bin . ' set_input ' . s:normal_cache)
    endif
endfunction

function! is#restore_insert()
    if exists('*jobstart')
        call jobstart([s:bin, 'set_input', s:insert_cache], {'on_stdout': function('is#nvim_set_normal_cache'), 'stdout_buffered': 1})
    elseif exists('*job_start')
        call job_start([s:bin, 'set_input', s:insert_cache], {'out_cb': function('is#vim_set_normal_cache')})
    else
        let s:normal_cache = system(s:bin . ' set_input ' . s:insert_cache)
    endif
endfunction

function! is#lazy_load()
    if exists('*jobstart')
        call jobstart(s:init_bin, {'on_stdout': function('is#nvim_init'), 'stdout_buffered': 1})
    elseif exists('*job_start')
        call job_start(s:init_bin, {'out_cb': function('is#vim_init')})
    else
        let s:ret_dict = eval(system(s:init_bin)[:-2])
        call init(s:ret_dict)
    endif
endfunction

function! is#input_trigger_enable()
    let s:input_trigger=1
endfunction

function! is#input_trigger_disable()
    let s:input_trigger=0
endfunction
