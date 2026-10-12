local log = require("tmux.log")

local M = {}

local function collect_panes(node, panes)
    if type(node) ~= "table" then
        return
    end
    if node.t == "p" then
        local id = type(node.I) == "string" and tonumber(node.I:match("^%%?(%d+)$")) or nil
        if id and node.x and node.y and node.w and node.h then
            table.insert(panes, { id = id, x = node.x, y = node.y, width = node.w, height = node.h })
        end
    elseif type(node.c) == "table" then
        for _, child in ipairs(node.c) do
            collect_panes(child, panes)
        end
    end
end

-- tmux >= 3.8 returns the layout in a JSON format (v2).
-- tmux < 3.8 returns the layout in a legacy format.
-- The legacy format will be removed in the future.
-- See https://github.com/tmux/tmux/blob/f980ef6427d2d4ee9b1461819f8ccf041622691d/layout-custom.c#L31-L32.

local function parse_json(display)
    local decoded = vim.json.decode(display)
    if type(decoded) ~= "table" or type(decoded.L) ~= "table" then
        log.error("window_layout returned invalid format")
        return nil
    end

    local panes = {}
    collect_panes(decoded.L, panes)
    if #panes == 0 then
        log.error("window_layout returned no valid panes")
        return nil
    end

    if not decoded.L.w or not decoded.L.h then
        log.error("window_layout returned invalid format")
        return nil
    end

    local result = { width = decoded.L.w, height = decoded.L.h, panes = panes }
    log.debug("parse > ", result)
    return result
end

local function parse_legacy(display)
    local panes = {}
    for pane in display:gmatch("(%d+x%d+,%d+,%d+,%d+)") do
        table.insert(panes, {
            id = tonumber(pane:match("%d+x%d+,%d+,%d+,(%d+)")),
            x = tonumber(pane:match("%d+x%d+,(%d+),%d+,%d+")),
            y = tonumber(pane:match("%d+x%d+,%d+,(%d+),%d+")),
            width = tonumber(pane:match("(%d+)x%d+")),
            height = tonumber(pane:match("%d+x(%d+)")),
        })
    end
    if #panes == 0 then
        log.error("window_layout returned no valid panes")
        return nil
    end

    local width = display:match("^%w+,(%d+)x%d+")
    local height = display:match("^%w+,%d+x(%d+)")

    if width == nil and height == nil then
        log.error("window_layout returned invalid format")
        return nil
    end

    local result = {
        width = tonumber(width),
        height = tonumber(height),
        panes = panes,
    }

    log.debug("parse > ", result)

    return result
end

function M.parse(display)
    log.debug("parse: ", display or "nil")

    if display == "" or display == nil then
        return nil
    end

    if display:sub(1, 1) == "{" then
        return parse_json(display)
    end

    return parse_legacy(display)
end

return M
