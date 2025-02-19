local log = require("tmux.log")
local parse = require("tmux.layout.parse")
local nvim = require("tmux.wrapper.nvim")
local tmux = require("tmux.wrapper.tmux")

local direction_checks = {
    ["h"] = function(_, pane)
        return pane.x == 0
    end,
    ["j"] = function(layout, pane)
        return pane.y + pane.height == layout.height
    end,
    ["k"] = function(_, pane)
        return pane.y == 0
    end,
    ["l"] = function(layout, pane)
        return pane.x + pane.width == layout.width
    end,
}

local function get_pane(id, panes)
    log.debug("get_pane: ", id)
    for _, pane in pairs(panes) do
        if pane.id == id then
            log.debug("get_pane > ", pane)
            return pane
        end
    end
    log.debug("get_pane > nil")
    return nil
end

local function check_is_border(display, id, direction)
    log.debug("check_is_border: ", { display, id, direction })

    local layout = parse.parse(display)
    if layout == nil then
        log.debug("check_is_border > nil")
        return nil
    end

    local pane = get_pane(id, layout.panes)
    if pane == nil then
        log.debug("check_is_border > nil")
        return nil
    end

    local check = direction_checks[direction]
    if check ~= nil then
        return check(layout, pane)
    end

    log.debug("check_is_border > nil")
    return nil
end

--return true if there is no other nvim window in the direction of @border
local function is_only_window(border)
    if border == "h" or border == "l" then
        --check for other horizontal window
        return (nvim.winnr("1h") == nvim.winnr("1l"))
    else
        --check for other vertical window
        return (nvim.winnr("1j") == nvim.winnr("1k"))
    end
end

local M = {}

function M.is_border(direction)
    log.debug("is_border: ", direction or "nil")

    local display = tmux.get_window_layout()
    local id = tmux.get_current_pane_id()
    local result = check_is_border(display, id, direction)

    log.debug("is_border > ", result or "false")

    return result
end

function M.is_tmux_target(border)
    if not tmux.is_tmux then
        return false
    end

    return not M.is_border(border) or is_only_window(border)
end

function M.has_tmux_target(direction, persist_zoom, cycle_navigation)
    if not tmux.is_tmux then
        return false
    end
    if tmux.is_zoomed() and persist_zoom then
        return false
    end
    if not M.is_border(direction) then
        return true
    end
    return cycle_navigation and not M.is_border(nvim.opposite_direction(direction))
end

return M
