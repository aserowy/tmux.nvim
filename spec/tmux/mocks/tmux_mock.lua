local tmux = require("tmux.wrapper.tmux")

local M = {}
function M.setup(tmux_version)
    tmux.is_tmux = true
    tmux.version = tmux_version

    tmux.setup = function() end
end

return M
