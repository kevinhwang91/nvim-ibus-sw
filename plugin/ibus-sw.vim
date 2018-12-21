let s:ibus_engine_trigger_enable=1

let g:ibus_default_engine = 'xkb:us::eng'

func! s:save_insert_engine()
    let s:insert_mode_engine=system('ibus engine')
endfunc


func! s:switch_normal_engine()
    silent execute "!ibus engine " . g:ibus_default_engine
endfunc

func! s:switch_insert_engine()
    if exists('s:insert_mode_engine')
        silent execute "!ibus engine " . s:insert_mode_engine
    endif
endfunc

func! Ibus_engine_trigger_enable()
    let s:ibus_engine_trigger_enable=1
    call s:save_insert_engine()
    call s:switch_normal_engine()
endfunc

func! Ibus_engine_trigger_disable()
    let s:ibus_engine_trigger_enable=0
    call s:switch_insert_engine()
endfunc

augroup ibus_engine
    au!
    autocmd InsertLeave * if s:ibus_engine_trigger_enable | :call s:save_insert_engine() | :call s:switch_normal_engine()
    autocmd InsertEnter * if s:ibus_engine_trigger_enable | :call s:switch_insert_engine()
augroup END

