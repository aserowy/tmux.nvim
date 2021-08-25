local log = require("tmux.log")

local M = {}

function M.parse(display)
    log.debug("parse: ", display or "nil")

    if display == "" or display == nil then
        return nil
    end

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

return M
