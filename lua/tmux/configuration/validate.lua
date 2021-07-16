local version = require("tmux.version")
local log = require("tmux.log")

local M = {}
function M.options(tmux_version, options)
    local current = version.new(tmux_version)
    if options.copy_sync.enable and options.copy_sync.redirect_to_clipboard then
        local valid_version = version.new("3.2")
        local compared = version.compare(current, valid_version)
        if compared.error ~= nil then
            log.error(compared.error)
        elseif compared.result < 0 then
            log.warning("redirect_to_clipboard: tmux version 3.2 is required, option reseted to false")
            options.copy_sync.redirect_to_clipboard = false
        end
    end
end

return M
