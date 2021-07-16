local M = {}
function M.new(value)
    return require("tmux.version.parse").from(value)
end

function M.compare(base, relative)
    return require("tmux.version.compare").with(base, relative)
end

return M
