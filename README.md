# tmux.nvim

![dependabot status](https://img.shields.io/badge/dependabot-enabled-025e8c?logo=Dependabot)
[![ci](https://github.com/aserowy/tmux.nvim/actions/workflows/ci.yaml/badge.svg)](https://github.com/aserowy/tmux.nvim/actions/workflows/ci.yaml)

## features

- navigating from nvim into tmux panes
- resizing nvim splits like tmux panes

## requirements

- neovim > 0.5

## installation

Install tmux.nvim with e.g. [packer.nvim](https://github.com/wbthomason/packer.nvim). The config step is only necessary to overwrite configuration defaults.

```lua
use({
    "aserowy/tmux.nvim"
    config = function()
        require("tmux").setup({
            -- overwrite default configuration
            -- here, e.g. to enable default bindings
            navigation = {
                -- enables default keybindings (C-hjkl) for normal mode
                enable_default_keybindings = true,
            },
            resize = {
                -- enables default keybindings (A-hjkl) for normal mode
                enable_default_keybindings = true,
            }
        })
    end
})
```

## configuration

The following defaults are given:

```lua
{
    navigation = {
        -- cycles to opposite pane while navigating into the border
        cycle_navigation = true,

        -- enables default keybindings (C-hjkl) for normal mode
        enable_default_keybindings = false,

        -- prevents unzoom tmux when navigating beyond vim border
        persist_zoom = false,
    },
    resize = {
        -- enables default keybindings (A-hjkl) for normal mode
        enable_default_keybindings = false,
    }
}
```

## usage


## contribute

Contributed code must pass [luacheck](https://github.com/mpeterv/luacheck) and be formatted with [stylua](https://github.com/johnnymorganz/stylua).

```sh
stylua lua/ && luacheck lua/
```
