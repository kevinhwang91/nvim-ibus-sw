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

autocmd InsertEnter * ++once :call is#lazy_load()
