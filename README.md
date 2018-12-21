# vim-ibus-sw

This plugin is for Vim users that use Ibus to handle multiple input methods when change between
normal and insert mode. (eg. English and Chinese)

The implement method is very simple.

Just save the ibus engine status before leaving insert mode and then switch default normal engine status.

Restore prev ibus engine status after entering insert mode.  

- - -

## Instalation

Use your plugin manager like [Vim-plug](https://github.com/junegunn/vim-plug)

Put this in your `~/.vimrc` or `~/.config/nvim/init.vim` if you using neovim. 

```vim 
Plug 'kevinhwang91/vim-ibus-sw'
```
Then restart vim and run `:PluginInstall` to install.

- - -

## Setup

You can replace default normal ibus engine status 'xkb:us:eng' with setting 'g:ibus_default_engine'.

When you use [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors), please appending below vim-multiple-cursors hook function in vim or neovim config file.

Without below hook function, the cpu load high and vim became very very slow when entering multiple edit using vim-multiple-cursors. 

```vim
function! Multiple_cursors_before()
    call Ibus_engine_trigger_disable()
endfunction
function! Multiple_cursors_after()
    call Ibus_engine_trigger_enable()
endfunction
```

I assume that principle of vim-multiple-cursors will often switch insert and normal mode causing this problem.

(I had't seen vim-multiple-cursors source code, but its author leaves this hook and many other plugins use it to solve this problem) 


