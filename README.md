# tmux.nvim

![dependabot status](https://img.shields.io/badge/dependabot-enabled-025e8c?logo=Dependabot)
[![ci](https://github.com/aserowy/tmux.nvim/actions/workflows/ci.yaml/badge.svg)](https://github.com/aserowy/tmux.nvim/actions/workflows/ci.yaml)

## features

### navigating from nvim into tmux panes

<https://user-images.githubusercontent.com/8199164/122721161-a026ce80-d270-11eb-9a27-2beff9910e69.mp4>

### resizing nvim splits like tmux panes

<https://user-images.githubusercontent.com/8199164/122721182-a61caf80-d270-11eb-9f75-0dd6343c0cb7.mp4>

## requirements

- neovim > 0.5

The plugin and `.tmux.conf` scripts are battle tested with

- tmux 3.0a

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

Tmux.nvim uses only `lua` api. If you are not running the default keybindings, you can bind the following functions to your liking. Besides the bindings in nvim you need to add configuration to tmux.

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
bind-key -T copy-mode-vi 'C-\' select-pane -l
```

If you are using [tmux plugin manager](https://github.com/tmux-plugins/tpm), you can add the following plugin. On a side note: This plugin sets the default keybindings and does not support cycle-free navigation:

```tmux
set -g @plugin 'christoomey/vim-tmux-navigator'

run '~/.tmux/plugins/tpm/tpm'
```

To run custom bindings in nvim, make sure to not set `enable_default_keybindings` to `true`. The following functions are used to navigate around windows and panes:

```lua
{
    [[<cmd>lua require'tmux'.move_left()<cr>]],
    [[<cmd>lua require'tmux'.move_bottom()<cr>]],
    [[<cmd>lua require'tmux'.move_top()<cr>]],
    [[<cmd>lua require'tmux'.move_right()<cr>]],
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
    [[<cmd>lua require'tmux'.resize_left()<cr>]],
    [[<cmd>lua require'tmux'.resize_bottom()<cr>]],
    [[<cmd>lua require'tmux'.resize_top()<cr>]],
    [[<cmd>lua require'tmux'.resize_right()<cr>]],
}
```

## contribute

Contributed code must pass [luacheck](https://github.com/mpeterv/luacheck) and be formatted with [stylua](https://github.com/johnnymorganz/stylua).

```sh
stylua lua/ && luacheck lua/
```

## inspiration

- [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)
- [Navigator.nvim](https://github.com/numToStr/Navigator.nvim)
