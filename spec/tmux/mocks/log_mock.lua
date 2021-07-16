local channels = require("tmux.log.channels")
local config = require("tmux.configuration.logging")

local M = {
    backet = "",
}

local function extend_backet(sev, message)
    M.backet = M.backet .. "\n" .. sev .. ": " .. message
end

function M.setup()
    channels.add("busted", extend_backet)

    config.set({
        busted = "debug",
    })
end

return M
