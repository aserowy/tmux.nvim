local keys = {
    "major",
    "minor",
    "patch",
}

local function has_key(table, key)
    return table[key] ~= nil
end

local function validate(version)
    local result = ""
    for _, value in ipairs(keys) do
        if not has_key(version, value) then
            result = result .. "entry for " .. value .. " is missing; "
        else
            if type(version[value]) ~= "number" then
                result = result .. "type for " .. value .. " is not number; "
            end
        end
    end

    if result == "" then
        return nil
    end

    return result
end

local function compare_by(key, base, relative)
    if base[key] > relative[key] then
        return 1
    elseif base[key] < relative[key] then
        return -1
    else
        return 0
    end
end

local M = {}
function M.with(base, relative)
    local validate_base = validate(base)
    if validate_base ~= nil then
        return { error = "base: " .. validate_base }
    end

    local validate_relative = validate(relative)
    if validate_relative ~= nil then
        return { error = "relative: " .. validate_relative }
    end

    for _, value in ipairs(keys) do
        local compared = compare_by(value, base, relative)
        if compared ~= 0 then
            return { result = compared }
        end
    end

    return { result = 0 }
end

return M
