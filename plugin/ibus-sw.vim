if get(g:, 'loaded_ibus_sw', 0)
    finish
endif

let g:loaded_ibus_sw = 1

if !executable('ibus')
    finish
endif

autocmd InsertEnter * ++once :call is#lazy_load()
