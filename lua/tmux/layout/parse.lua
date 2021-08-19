local M = {}

function M.parse(display)
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

    local width = display:match("(%d+)x%d+")
    local height = display:match("%d+x(%d+)")

    return {
        width = tonumber(width),
        height = tonumber(height),
        panes = panes,
    }
end

return M
