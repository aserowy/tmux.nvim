local config = require("tmux.configuration")
local copy = require("tmux.copy")
local log = require("tmux.log")
local navigate = require("tmux.navigate")
local resize = require("tmux.resize")
local tmux = require("tmux.wrapper.tmux")

local M = {
    move_left = navigate.to_left,
    move_bottom = navigate.to_bottom,
    move_top = navigate.to_top,
    move_right = navigate.to_right,

    post_yank = copy.post_yank,
    sync_registers = copy.sync_registers,

    resize_left = resize.to_left,
    resize_bottom = resize.to_bottom,
    resize_top = resize.to_top,
    resize_right = resize.to_right,
}

function M.setup(options, logging)
    log.setup()

    log.debug("setup tmux wrapper")
    if not tmux.setup() then
        log.information("setup for tmux wrapper failed")
        return
    end

    log.debug("setup config")
    config.setup(options, logging)

    log.debug("setup copy")
    copy.setup()

    log.debug("setup navigate")
    navigate.setup()

    log.debug("setup resize")
    resize.setup()
end

return M
