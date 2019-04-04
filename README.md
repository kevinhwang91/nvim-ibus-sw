# vim-ibus-sw

This plugin is for Vim users that use Ibus to handle multiple input methods when change between
normal and insert mode. (eg. English and Chinese)

The implement method is very simple.

Just save the ibus input status before leaving insert mode and then switch default normal status.

Restore prev ibus input status after entering insert mode.

---

## Installation

Use your plugin manager like [Vim-plug](https://github.com/junegunn/vim-plug)

Put this in your `~/.vimrc` or `~/.config/nvim/init.vim` if you using neovim.

```vim
Plug 'kevinhwang91/vim-ibus-sw'
```

Then restart vim and run `:PluginInstall` to install.

---

## Principle

If you use Desktop isn't Gnome, the plugin switch keyboard input using raw 'ibus engine' command.

This brings a bug using 'Allow different sources for each window' option in input settings becasue every progress has a session fragment to save the input status.

Raw 'ibus engine' can't change this session. Therefore, When you Focus Lost vim window and return back latter, Gnome Desktop will restore the session for raw input status.

However, I use 'FocusGained' action in vim to restore the normal status by 'ibus engine', It solves the single vim wndows problem, but if you using vim inside tmux, switch to tmux other pane and then focus lost tmux, it will lead to the lastest pane become insert mode input status because of the unchanged session.

Using Gnome Desktop which default keyboard input is ibus. Switching input by 'Gdbus', which can change the session, it seem no problem any more.

So using 'Gdbus' is the first choice.

---

## Setup

1. Using Gnome  
You have option to replace your normal input index by 'g:default_input_index', default is 0, your first input.  
  
2. Without using Gnome  
You have option to replace you normal input engine by 'g:ibus_default_engine', default is 'xkb:us:eng'.

When you use [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors), please appending below vim-multiple-cursors hook function in vim or neovim config file.

Without below hook function, the cpu load high and vim became very very slow when entering multiple edit using vim-multiple-cursors.

```vim
function! Multiple_cursors_before()
    call Ibus_input_trigger_disable()
endfunction
function! Multiple_cursors_after()
    call Ibus_input_trigger_enable()
endfunction
```

I assume that principle of vim-multiple-cursors will often switch insert and normal mode causing this problem.

(I had't seen vim-multiple-cursors source code, but its author leaves this hook and many other plugins use it to solve this problem)

### Suggest

Anyway, I suggest you use [vim-visual-multi](https://github.com/mg979/vim-visual-multi) instead of [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors), faster and have other awesome features.

Using vim-visual-multi, It doesn't use hook function like vim-multiple-cursors anymore!!!

## Demonstration
![image](./vim-ibus-sw.gif)
