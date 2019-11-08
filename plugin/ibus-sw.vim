if exists('g:loaded_ibus_sw')
  finish
endif

let g:loaded_ibus_sw = 1

if !executable('ibus')
    finish
endif

if !get(g:, 'ibus_sw_enable', 1)
    finish
end

let s:ibus_input_trigger=1
let s:init_bin = expand("<sfile>:h:h") . "/bin/init.sh"

function! s:init(ret_dict)
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
    augroup ibus_input
        au!
        autocmd InsertLeave * if s:ibus_input_trigger | :call s:restore_normal()
        autocmd InsertEnter * if s:ibus_input_trigger | :call s:restore_insert()
        if s:itype == 'engine'
            autocmd FocusGained * if s:insert_cache != s:normal_cache | if mode()!='i'| sleep 200m | :call s:restore_normal()
        endif
    augroup END
endfunction

" neovim asynchronous callback function
" ======================================================
function! s:nvim_init(job_id, data, event)
    let s:ret_dict = eval(a:data[0])
    call s:init(s:ret_dict)
endfunction

function! s:nvim_set_insert_cache(job_id, data, event)
    let s:insert_cache = a:data[0]
endfunction

function! s:nvim_set_normal_cache(job_id, data, event)
    let s:normal_cache = a:data[0]
endfunction
" ======================================================

" vim asynchronous callback function
" ======================================================
function! s:vim_init(channel, data)
    let s:ret_dict = eval(a:data)
    call s:init(s:ret_dict)
endfunction

function! s:vim_set_insert_cache(channel, data)
    let s:insert_cache = a:data
endfunction

function! s:vim_set_normal_cache(channel, data)
    let s:normal_cache = a:data
endfunction
" ======================================================

function! s:restore_normal()
    if exists('*jobstart')
        call jobstart([s:bin, 'set_input', s:normal_cache], {'on_stdout': function('s:nvim_set_insert_cache'), 'stdout_buffered': 1})
    elseif exists('*job_start')
        call job_start([s:bin, 'set_input', s:normal_cache], {'out_cb': function('s:vim_set_insert_cache')})
    else
        let s:insert_cache = system(s:bin . ' set_input ' . s:normal_cache)
    endif
endfunction

function! s:restore_insert()
    if exists('*jobstart')
        call jobstart([s:bin, 'set_input', s:insert_cache], {'on_stdout': function('s:nvim_set_normal_cache'), 'stdout_buffered': 1})
    elseif exists('*job_start')
        call job_start([s:bin, 'set_input', s:insert_cache], {'out_cb': function('s:vim_set_normal_cache')})
    else
        let s:normal_cache = system(s:bin . ' set_input ' . s:insert_cache)
    endif
endfunction

function! s:lazy_load()
    if exists('*jobstart')
        call jobstart(s:init_bin, {'on_stdout': function('s:nvim_init'), 'stdout_buffered': 1})
    elseif exists('*job_start')
        call job_start(s:init_bin, {'out_cb': function('s:vim_init')})
    else
        let s:ret_dict = eval(system(s:init_bin)[:-2])
        call s:init(s:ret_dict)
    endif
endfunction

autocmd InsertEnter * ++once :call s:lazy_load()

function! Ibus_input_trigger_enable()
    let s:ibus_input_trigger=1
endfunction

function! Ibus_input_trigger_disable()
    let s:ibus_input_trigger=0
endfunction
