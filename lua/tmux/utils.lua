local layout = require("tmux.layout")
local nvim = require("tmux.wrapper.nvim")
local tmux = require("tmux.wrapper.tmux")

local M = {}

--return true if there is no other nvim window in the direction of @border
function M.is_only_window(border)
    if border == "h" or border == "l" then
        --check for other horizontal window
        return (nvim.winnr("1h") == nvim.winnr("1l"))
    else
        --check for other vertical window
        return (nvim.winnr("1j") == nvim.winnr("1k"))
    end
end

function M.is_tmux_target(border)
    if not tmux.is_tmux then
        return false
    end

    return not layout.is_border(border) or M.is_only_window(border)
end

function M.has_tmux_target(direction, persist_zoom, cycle_navigation)
    if not tmux.is_tmux then
        return false
    end
    if tmux.is_zoomed() and persist_zoom then
        return false
    end
    if not layout.is_border(direction) then
        return true
    end
    return cycle_navigation and not layout.is_border(M.opposite_direction(direction))
end

function M.opposite_direction(direction)
    local opposite_directions = { h = "l", j = "k", k = "j", l = "h" }
    return opposite_directions[direction]
end

return M
