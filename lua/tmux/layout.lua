local tmux = require("tmux.tmux")

local function parse(display)
    if display == "" or not display then
        return
    end

    local panes = {}
    for pane in display:gmatch("(%d+x%d+,%d+,%d+,%d+)") do
        panes[#panes+1] = {
            id = tonumber(pane:match("%d+x%d+,%d+,%d+,(%d+)")),
            x = tonumber(pane:match("%d+x%d+,(%d+),%d+,%d+")),
            y = tonumber(pane:match("%d+x%d+,%d+,(%d+),%d+")),
            width = tonumber(pane:match("(%d+)x%d+")),
            height = tonumber(pane:match("%d+x(%d+)")),
        }
    end
    if #panes == 0 then
        return
    end

    local width = display:match("^%w+,(%d+)x%d+")
    local height = display:match("^%w+,%d+x(%d+)")

    if not width and not height then
        return
    end

    local result = {
        width = tonumber(width),
        height = tonumber(height),
        panes = panes,
    }

    return result
end

local direction_checks = {
    h = function(_, pane)
        return pane.x == 0
    end,

    j = function(layout, pane)
        return pane.y + pane.height == layout.height
    end,

    k = function(_, pane)
        return pane.y == 0
    end,

    l = function(layout, pane)
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

local M = {}

function M.is_border(direction)
    local display = tmux.get_window_layout()
    local id = tmux.get_current_pane_id()

    local layout = parse(display)
    if not layout then
        return
    end

    local pane = get_pane(id, layout.panes)
    if not pane then
        return
    end

    local check = direction_checks[direction]
    if check ~= nil then
        return check(layout, pane)
    end

    return
end

return M
