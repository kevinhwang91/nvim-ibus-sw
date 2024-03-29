# nvim-ibus-sw

Be eased to handle multiple inputs methods when changing between normal and insert mode(eg. English and Chinese).

<https://user-images.githubusercontent.com/17562139/200020687-9d5487cf-4176-4f3a-9e77-ab842e3c7ce9.mp4>

---

## Features

- Save and restore input method when entering/leaving insert mode
- Switch input method asynchronously

## Requirements

- [Ibus](https://github.com/ibus/ibus)
- [Neovim](https://github.com/neovim/neovim) 0.6.1 or later

## Installation

Install with [Packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use {'kevinhwang91/nvim-ibus-sw'}
```

> WIP, I may add extra Lua dependences in the further :)

### Minimal configuration

```lua
use {'kevinhwang91/nvim-ibus-sw', event = 'InsertEnter',
     config = function()
         require('ibus-sw').setup()
     end
}
```

## Gnome users suggestions

1. Use [gnome-shell-ibus-switcher](https://github.com/kevinhwang91/gnome-shell-ibus-switcher) to
   switch input methods that can refresh the input indicator in tray and restore InputMode.
2. Enable to switch input sources individually for each window,
   `gsettings set org.gnome.desktop.input-sources per-window true`

You can skip (Limitation)[#Limitation] section :)

## Limitation

**If you aren't a Gnome user, the plugin switch input method by `ibus engine` command. When
switching input method, tray icon of ibus change nothing.**

Using `ibus engine` brings a bug when using `switch input sources individually for each window`
option in input settings in Gnome Desktop Environment, because every progress has a session to save
the input status, and restore the data from the session when you refocus on the application.

`ibus engine` can't change this session. Therefore, when you focus lost Neovim window and return
back later, Gnome Desktop will restore the session for raw input status.

## License

The project is licensed under a BSD-3-clause license. See the [LICENSE](./LICENSE) file.
