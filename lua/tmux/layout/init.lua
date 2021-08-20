local tmux = require("tmux.wrapper")
local parse = require("tmux.layout.parse")

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
    for _, pane in pairs(panes) do
        if pane.id == id then
            return pane
        end
    end
    return nil
end

local function check_is_border(display, id, direction)
    local layout = parse.parse(display)
    if layout == nil then
        return nil
    end

    local pane = get_pane(id, layout.panes)
    if pane == nil then
        return nil
    end

    local check = direction_checks[direction]
    if check ~= nil then
        return check(layout, pane)
    end

    return nil
end

local M = {}

function M.is_border(direction)
    local display = tmux.get_window_layout()
    local id = tmux.get_current_pane_id()

    return check_is_border(display, id, direction)
end

return M
