local wrapper = require("tmux.wrapper")

local M = {}
function M.setup(tmux_version)
    wrapper.is_tmux = true
    wrapper.version = tmux_version

    wrapper.setup = function() end
end

return M
