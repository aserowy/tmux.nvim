local CTOR = {}

function CTOR.create(notify_func, severity_map)
    local M = {}

    if notify_func then
        M.notify = notify_func
    else
        M.notify = vim.notify
    end

    if severity_map then
        M.severity_map = severity_map
    else
        M.severity_map = {
            debug = vim.log.levels.DEBUG,
            error = vim.log.levels.ERROR,
            information = vim.log.levels.INFO,
            trace = vim.log.levels.TRACE,
            warning = vim.log.levels.WARN,
        }
    end

    function M.convert_severity(sev)
        if not sev or sev == "" then
            return nil
        end

        return M.severity_map[sev]
    end

    function M.write(sev, message)
        if not message or message == "" then
            return
        end

        local severity = M.convert_severity(sev)
        if not severity then
            return
        end

        M.notify(message, severity, nil)
    end

    return M
end

return CTOR
