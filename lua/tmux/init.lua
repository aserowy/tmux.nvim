local config = require("tmux.configuration")
local copy = require("tmux.copy")
local log = require("tmux.log")
local navigation = require("tmux.navigation")
local resize = require("tmux.resize")
local swap = require("tmux.swap")
local tmux = require("tmux.wrapper.tmux")

local options = {
    copy_sync = {
        enable = true,
    },
    navigation = {
        enable_default_keybindings = true,
    },
    resize = {
        enable_default_keybindings = true,
    },
    swap = {
        enable_default_keybindings = true,
    },
}

local M = {
    move_left = navigation.to_left,
    move_bottom = navigation.to_bottom,
    move_top = navigation.to_top,
    move_right = navigation.to_right,

    post_yank = copy.post_yank,
    sync_registers = copy.sync_registers,

    resize_left = resize.to_left,
    resize_bottom = resize.to_bottom,
    resize_top = resize.to_top,
    resize_right = resize.to_right,

    swap_left = swap.to_left,
    swap_bottom = swap.to_bottom,
    swap_top = swap.to_top,
    swap_right = swap.to_right,
}

function M.setup(options_, logging)
    if options_ then
        for k, v in pairs(options_) do
            options[k] = v
        end
    end

    log.setup()

    log.debug("setup tmux wrapper")
    tmux.setup()

    log.debug("setup config")
    config.setup(options, logging)

    log.debug("setup copy")
    copy.setup()

    log.debug("setup navigate")
    navigation.setup()

    log.debug("setup resize")
    resize.setup()

    log.debug("setup swap")
    swap.setup()
end

return M
