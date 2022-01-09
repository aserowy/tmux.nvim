local log = require("tmux.log")

local function get_order(char)
    if char == nil or char == "" then
        return 0
    end
    return string.byte(char) - string.byte("a") + 1
end

local M = {}
function M.from(value)
    if value == nil then
        log.error("nil could not get parsed!")
        return {}
    end

    value = value:gsub("next%-?", "")
    if value:match("^%d+%.%d+[a-z]?$") == nil then
        log.error(value .. " could not get parsed!")
        return {}
    end

    local index_dot = value:find("%.")
    local index_patch = value:find("[a-z]")

    local minor
    if index_patch == nil then
        minor = tonumber(value:sub(index_dot + 1))
    else
        minor = tonumber(value:sub(index_dot + 1, index_patch - 1))
    end

    local patch = 0
    if index_patch ~= nil then
        patch = get_order(value:sub(index_patch))
    end

    return {
        major = tonumber(value:sub(1, index_dot - 1)),
        minor = minor,
        patch = patch,
    }
end

return M
