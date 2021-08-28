local layout = require("tmux.layout")
local log = require("tmux.log")
local nvim = require("tmux.wrapper.nvim")
local options = require("tmux.configuration.options")
local tmux = require("tmux.wrapper.tmux")

local opposite_directions = {
    h = "l",
    j = "k",
    k = "j",
    l = "h",
}

local M = {}
function M.has_tmux_target(direction)
    if not tmux.is_tmux then
        return false
    end
    if tmux.is_zoomed() and options.navigation.persist_zoom then
        return false
    end
    if not layout.is_border(direction) then
        return true
    end
    return options.navigation.cycle_navigation and not layout.is_border(opposite_directions[direction])
end

function M.to(direction)
    log.debug("navigate_to: " .. direction)

    local is_nvim_border = nvim.is_nvim_border(direction)
    if is_nvim_border and M.has_tmux_target(direction) then
        tmux.change_pane(direction)
    elseif is_nvim_border and options.navigation.cycle_navigation then
        nvim.wincmd(opposite_directions[direction], 999)
    elseif not is_nvim_border then
        nvim.wincmd(direction)
    end
end

return M
