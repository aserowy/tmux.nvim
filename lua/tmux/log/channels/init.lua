local config = require("tmux.configuration.logging")
local severity = require("tmux.log.severity")

local M = {
    current = {},
}

function M.add(channel, func)
    if channel == nil or type(channel) ~= "string" then
        return
    end
    if func == nil or type(func) ~= "function" then
        return
    end
    M.current[channel] = func
end

function M.log(sev, message)
    for key, value in pairs(M.current) do
        if severity.check(config[key], sev) then
            xpcall(function()
                value(sev, message)
            end, function(error)
                print("ERROR: Logging for channel " .. key .. " failed.", error)
            end)
        end
    end
end

return M
