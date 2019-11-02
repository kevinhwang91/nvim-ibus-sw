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

    let s:gdbus_ctrl = 'gdbus call -e -d org.gnome.Shell -o /org/gnome/Shell -m org.gnome.Shell.Eval '
    let s:get_input_index = '"imports.ui.status.keyboard.getInputSourceManager().currentSource.index"'
    let s:set_input_index_prefix = '"imports.ui.status.keyboard.getInputSourceManager().inputSources['
    let s:set_input_index_suffix = '].activate()" > /dev/null'
    let s:gdbus_get_cmd = printf("%s%s", s:gdbus_ctrl, s:get_input_index)
    function! s:gome_on_event(job_id, data, event)
        let ret_index = a:data[0]
        if empty(ret_index)
            let s:insert_input_index = s:normal_input_index
        else
            let s:insert_input_index = ret_index
        endif
    endfunction
    function! Gome_on_evente(channel, msg)
        " let ret_index = a:data[0]
        " if empty(ret_index)
            " let s:insert_input_index = s:normal_input_index
        " else
            " let s:insert_input_index = ret_index
        " endif
        echom a:msg
    endfunction
    func! s:restore_normal()
            let gdbus_set_normal_cmd = printf("%s%s%d%s", s:gdbus_ctrl, s:set_input_index_prefix, s:normal_input_index, s:set_input_index_suffix)
            let start_time = reltime()
            if exists('*jobstart')
                call jobstart('ret=$(' . s:gdbus_get_cmd . " | cut -d \\' -f 2) && [[ $ret != " . s:normal_input_index . ' ]] && ' . gdbus_set_normal_cmd . ' && echo $ret', {'on_stdout': function('s:gome_on_event'), 'stdout_buffered': 1})
            elseif exists('*job_start')
                call job_start('ret=$(' . s:gdbus_get_cmd . " | cut -d \\' -f 2) && [[ $ret != " . s:normal_input_index . ' ]] && ' . gdbus_set_normal_cmd . ' && echo $ret', {'out_cb': 'Gome_on_evente'})
                " let s:insert_input_index=substitute(system(s:gdbus_get_cmd), '\v.*(\d).*', '\=submatch(1)', '')
                " if s:insert_input_index!=s:normal_input_index
                    " silent execute '!' . gdbus_set_normal_cmd
                " endif
            else
                let s:insert_input_index=substitute(system(s:gdbus_get_cmd), '\v.*(\d).*', '\=submatch(1)', '')
                if s:insert_input_index!=s:normal_input_index
                    silent execute '!' . gdbus_set_normal_cmd
                endif
            endif
            " echo "elapsed time:" reltimestr(reltime(start_time))
    endfunc

    func! s:restore_insert()
        if s:insert_input_index!=s:normal_input_index
            let gdbus_set_insert_cmd = printf("%s%s%d%s", s:gdbus_ctrl, s:set_input_index_prefix, s:insert_input_index, s:set_input_index_suffix)
            if exists('*jobstart')
                call jobstart(gdbus_set_insert_cmd)
            elseif exists('*job_start')
                silent execute '!' . gdbus_set_insert_cmd
            else
                silent execute '!' . gdbus_set_insert_cmd
            endif
        endif

    endfunc
else
    if !exists("g:defaul_input_name")
        let g:defaul_input_name='xkb:us::eng'
    endif
    let s:normal_input_name=g:defaul_input_name
    let s:insert_input_name=s:normal_input_name

    function! s:on_event(job_id, data, event)
        let ret_str = join(a:data, '')
        if len(ret_str) > 0
            let s:insert_input_name = ret_str
        else
            let s:insert_input_name = s:normal_input_name
        endif
    endfunction

    func! s:restore_normal()
            " let start_time = reltime()
            " let s:insert_input_name=system('ibus engine')[:-2]
            " if s:insert_input_name != s:normal_input_name
                " silent execute "!ibus engine " . s:normal_input_name
            " endif
            call jobstart('ret=$(ibus engine) && [[ "'. s:normal_input_name . '" != "$ret" ]] && ibus engine "' . s:normal_input_name . '" > /dev/null && echo $ret', {'on_stdout': function('s:on_event'), 'stdout_buffered': 1})
            " echo "elapsed time:" reltimestr(reltime(start_time))
        " endif
    endfunc

    func! s:restore_insert()
        if s:insert_input_name!=s:normal_input_name
            call jobstart(['ibus', 'engine', s:insert_input_name])
            " silent execute "!ibus engine " . s:insert_input_name
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
    autocmd InsertLeave * if s:ibus_input_trigger | :call s:restore_normal()
    autocmd InsertEnter * if s:ibus_input_trigger | :call s:restore_insert()
    if !s:is_gnome
        autocmd FocusGained * if s:insert_input_name != s:normal_input_name | if mode()!='i'| sleep 200m | :call s:restore_normal()
    endif
augroup END

