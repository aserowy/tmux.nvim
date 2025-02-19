local layout = require("tmux.layout")
local log = require("tmux.log")
local nvim = require("tmux.wrapper.nvim")
local options = require("tmux.configuration.options")
local tmux = require("tmux.wrapper.tmux")

local M = {}

function M.to(direction)
    log.debug("navigate_to: " .. direction)

    local is_nvim_border = nvim.is_nvim_border(direction)
    local has_tmux_target =
        layout.has_tmux_target(direction, options.navigation.persist_zoom, options.navigation.cycle_navigation)
    if (nvim.is_nvim_float() or is_nvim_border) and has_tmux_target then
        tmux.change_pane(direction)
    elseif is_nvim_border and options.navigation.cycle_navigation then
        nvim.wincmd(nvim.opposite_direction(direction), 999)
    elseif not is_nvim_border then
        nvim.wincmd(direction, vim.v.count)
    end
end

return M
