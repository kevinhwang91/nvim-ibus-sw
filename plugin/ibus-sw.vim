if !executable('ibus')
    finish
endif

let s:ibus_input_trigger=1
let s:is_gnome=($DESKTOP_SESSION=='gnome')
if s:is_gnome
    " let s:input_size=substitute(system('gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval "Object.keys(imports.ui.status.keyboard.getInputSourceManager().inputSources).length"'),'.*\v(\d).*', '\=submatch(1)', '')
    " if s:input_size<2
        " finish
    " endif
    if !exists("g:default_input_index")
        let g:default_input_index=0
    endif
    let s:normal_input_index=g:default_input_index
    let s:insert_input_index=s:normal_input_index
    let s:dbus_ctrl='!gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval '
    func! s:store_insert()
        let s:insert_input_index=substitute(system('gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval "imports.ui.status.keyboard.getInputSourceManager().currentSource.index"'), '.*\v(\d).*', '\=submatch(1)', '')
    endfunc
    func! s:restore_normal()
        if s:insert_input_index!=s:normal_input_index
            silent execute s:dbus_ctrl . '"imports.ui.status.keyboard.getInputSourceManager().inputSources['.g:default_input_index.'].activate()"'
        endif
    endfunc

    func! s:restore_insert()
        if s:insert_input_index!=s:normal_input_index
            silent execute s:dbus_ctrl . '"imports.ui.status.keyboard.getInputSourceManager().inputSources['.s:insert_input_index.'].activate()"'
        endif
    endfunc
else
    if !exists("g:defaul_input_name")
        let g:defaul_input_name='xkb:us::eng'
    endif
    let s:normal_input_name=g:defaul_input_name
    let s:insert_input_name=s:normal_input_name

    func! s:store_insert()
        let s:insert_input_name=system('ibus engine')[:-2]
    endfunc

    func! s:restore_normal()
        if s:insert_input_name!=s:normal_input_name
            silent execute "!ibus engine " . s:normal_input_name
        endif
    endfunc

    func! s:restore_insert()
        if s:insert_input_name!=s:normal_input_name
            silent execute "!ibus engine " . s:insert_input_name
        endif
    endfunc
endif



func! Ibus_input_trigger_enable()
    let s:ibus_input_trigger=1
    call s:store_insert()
    call s:restore_normal()
endfunc

func! Ibus_input_trigger_disable()
    let s:ibus_input_trigger=0
    call s:restore_insert()
endfunc

augroup ibus_input
    au!
    autocmd InsertLeave * if s:ibus_input_trigger | :call s:store_insert() | :call s:restore_normal()
    autocmd InsertEnter * if s:ibus_input_trigger | :call s:restore_insert()
    if !s:is_gnome
        autocmd FocusGained * if s:insert_input_name!=s:normal_input_name | if mode()!='i'| sleep 100m | :call s:restore_normal()
    endif
augroup END

