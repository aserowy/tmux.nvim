# tmux.nvim

![dependabot](https://img.shields.io/badge/dependabot-enabled-025e8c?logo=Dependabot)
[![ci](https://github.com/aserowy/tmux.nvim/actions/workflows/ci.yaml/badge.svg)](https://github.com/aserowy/tmux.nvim/actions/workflows/ci.yaml)
[![coverage](https://coveralls.io/repos/github/aserowy/tmux.nvim/badge.svg?branch=main)](https://coveralls.io/github/aserowy/tmux.nvim?branch=main)

## features

### copy from nvim to nvim to tmux

<https://user-images.githubusercontent.com/8199164/124225235-5f984200-db07-11eb-9cff-ab73be12b4b1.mp4>

### navigating from nvim into tmux panes

<https://user-images.githubusercontent.com/8199164/122721161-a026ce80-d270-11eb-9a27-2beff9910e69.mp4>

### resizing nvim splits like tmux panes

<https://user-images.githubusercontent.com/8199164/122721182-a61caf80-d270-11eb-9f75-0dd6343c0cb7.mp4>

## requirements

- neovim >= 0.5

The plugin and `.tmux.conf` scripts are battle tested with

- tmux 3.2a

## installation

Install tmux.nvim with e.g. [packer.nvim](https://github.com/wbthomason/packer.nvim). The config step is only necessary to overwrite configuration defaults.

```lua
use({
    "aserowy/tmux.nvim",
    config = function()
        require("tmux").setup({
            -- overwrite default configuration
            -- here, e.g. to enable default bindings
            copy_sync = {
                -- enables copy sync and overwrites all register actions to
                -- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
                enable = true,
            },
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
    copy_sync = {
        -- enables copy sync. by default, all registers are synchronized.
        -- to control which registers are synced, see the `sync_*` options.
        enable = false,

        -- ignore specific tmux buffers e.g. buffer0 = true to ignore the
        -- first buffer or named_buffer_name = true to ignore a named tmux
        -- buffer with name named_buffer_name :)
        ignore_buffers = { empty = false },

        -- TMUX >= 3.2: all yanks (and deletes) will get redirected to system
        -- clipboard by tmux
        redirect_to_clipboard = false,

        -- offset controls where register sync starts
        -- e.g. offset 2 lets registers 0 and 1 untouched
        register_offset = 0,

        -- overwrites vim.g.clipboard to redirect * and + to the system
        -- clipboard using tmux. If you sync your system clipboard without tmux,
        -- disable this option!
        sync_clipboard = true,

        -- synchronizes registers *, +, unnamed, and 0 till 9 with tmux buffers.
        sync_registers = true,

        -- syncs deletes with tmux clipboard as well, it is adviced to
        -- do so. Nvim does not allow syncing registers 0 and 1 without
        -- overwriting the unnamed register. Thus, ddp would not be possible.
        sync_deletes = true,

        -- syncs the unnamed register with the first buffer entry from tmux.
        sync_unnamed = true,
    },
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

        -- sets resize steps for x axis
        resize_step_x = 1,

        -- sets resize steps for y axis
        resize_step_y = 1,
    }
}
```

## usage

Tmux.nvim uses only `lua` API. If you are not running the default keybindings, you can bind the following functions to your liking. Besides the bindings in nvim you need to add configuration to tmux.

### copy sync

Copy sync uses tmux buffers as master clipboard for `*`, `+`, `unnamed`, and `0` - `9` registers. The sync does NOT rely on temporary files and works just with the given tmux API. Thus, making it less insecure :). The feature enables a nvim instace overarching copy/paste process! dd in one nvim instance, switch to the second and p your deletes.

If you sync your clipboard not with a standalone tmux, disable `sync_clipboard` to ensure nvim handles yanks and deletes alone.

This has some downsites, on really slow machines, calling registers or pasting will eventually produce minimal input lag by syncing registers in advance to ensure the correctness of state. To avoid this, disabling `sync_registers` will only redirect the `*` and `+` registers.

To redirect copies (and deletes) to clipboard, tmux must have the capability to do so. The plugin will just set -w on set-buffer. If your tmux need more configuration check out [tmux-yank](https://github.com/tmux-plugins/tmux-yank) for an easy setup.

Ignoring buffers must have the form of `buffer_name = true` to enable an unsorted list in lua. This enhances the performance of checks - if a buffer is ignored or not - meaningfull.

### navigation

To enable cycle-free navigation beyond nvim, add the following to your `~/.tmux.conf`:

> It is important to note, that your bindings in nvim must match the defined bindings in tmux! Otherwise the pass through will not have the seamless effect!

```tmux
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' { if -F '#{pane_at_left}' '' 'select-pane -L' }
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' { if -F '#{pane_at_bottom}' '' 'select-pane -D' }
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' { if -F '#{pane_at_top}' '' 'select-pane -U' }
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' { if -F '#{pane_at_right}' '' 'select-pane -R' }

bind-key -T copy-mode-vi 'C-h' if -F '#{pane_at_left}' '' 'select-pane -L'
bind-key -T copy-mode-vi 'C-j' if -F '#{pane_at_bottom}' '' 'select-pane -D'
bind-key -T copy-mode-vi 'C-k' if -F '#{pane_at_top}' '' 'select-pane -U'
bind-key -T copy-mode-vi 'C-l' if -F '#{pane_at_right}' '' 'select-pane -R'
```

Otherwise you can add:

```tmux
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

bind-key -T copy-mode-vi 'C-h' select-pane -L
bind-key -T copy-mode-vi 'C-j' select-pane -D
bind-key -T copy-mode-vi 'C-k' select-pane -U
bind-key -T copy-mode-vi 'C-l' select-pane -R
```

If you are using [tmux plugin manager](https://github.com/tmux-plugins/tpm), you can add the following plugin. On a side note: This plugin sets the default keybindings and does not support cycle-free navigation:

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'

run '~/.tmux/plugins/tpm/tpm'
```

To run custom bindings in nvim, make sure to set `enable_default_keybindings` to `false`. The following functions are used to navigate around windows and panes:

```lua
{
    [[<cmd>lua require("tmux").move_left()<cr>]],
    [[<cmd>lua require("tmux").move_bottom()<cr>]],
    [[<cmd>lua require("tmux").move_top()<cr>]],
    [[<cmd>lua require("tmux").move_right()<cr>]],
}
```

### resize

Add the following bindings to your `~/.tmux.conf`:

> It is important to note, that your bindings in nvim must match the defined bindings in tmux! Otherwise the pass through will not have the seamless effect!

```tmux
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind -n 'M-h' if-shell "$is_vim" 'send-keys M-h' 'resize-pane -L 1'
bind -n 'M-j' if-shell "$is_vim" 'send-keys M-j' 'resize-pane -D 1'
bind -n 'M-k' if-shell "$is_vim" 'send-keys M-k' 'resize-pane -U 1'
bind -n 'M-l' if-shell "$is_vim" 'send-keys M-l' 'resize-pane -R 1'

bind-key -T copy-mode-vi M-h resize-pane -L 1
bind-key -T copy-mode-vi M-j resize-pane -D 1
bind-key -T copy-mode-vi M-k resize-pane -U 1
bind-key -T copy-mode-vi M-l resize-pane -R 1
```

To run custom bindings in nvim, make sure to not set `enable_default_keybindings` to `true`. The following functions are used to resize windows:

```lua
{
    [[<cmd>lua require("tmux").resize_left()<cr>]],
    [[<cmd>lua require("tmux").resize_bottom()<cr>]],
    [[<cmd>lua require("tmux").resize_top()<cr>]],
    [[<cmd>lua require("tmux").resize_right()<cr>]],
}
```

## contribute

Contributed code must pass [luacheck](https://github.com/mpeterv/luacheck) and be formatted with [stylua](https://github.com/johnnymorganz/stylua). Besides formatting, all tests have to pass. Tests are written for [busted](https://github.com/Olivine-Labs/busted).

If you are using nix-shell, you can start a nix-shell and run `fac` (format and check).

```sh
stylua lua/ && luacheck lua/ && busted --verbose
```

## inspiration

### clipboard harmonization

- [Clipboard integration between tmux, nvim, zsh, x11, across SSH sessions](https://blog.landofcrispy.com/index.php/2021/01/06/clipboard-integration-between-tmux-nvim-zsh-x11-across-ssh-sessions/)
- [Everything you need to know about Tmux copy paste - Ubuntu](http://www.rushiagr.com/blog/2016/06/16/everything-you-need-to-know-about-tmux-copy-pasting-ubuntu/)

### navigation & resizing

- [better-vim-tmux-resizer](https://github.com/RyanMillerC/better-vim-tmux-resizer)
- [Navigator.nvim](https://github.com/numToStr/Navigator.nvim)
- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
