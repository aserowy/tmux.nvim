local valid_severities = {
    disabled = 0,
    debug = 1,
    information = 2,
    warning = 3,
    error = 4,
}

local function validate(sev)
    if sev == nil or type(sev) ~= "string" or sev == "" then
        return false
    end
    if valid_severities[sev] == nil then
        return false
    end
    return true
end

local M = {}
function M.check(barrier, sev)
    if not validate(sev) or not validate(barrier) then
        return false
    end
    local barrier_priority = valid_severities[barrier]
    if barrier_priority == 0 then
        return false
    end
    return barrier_priority <= valid_severities[sev]
end

function M.validate(sev)
    return validate(sev)
end

return M
