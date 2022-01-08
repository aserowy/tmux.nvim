local M = {
    file = "warning",
    notify = "warning",
}

function M.set(options)
    if options == nil or options == "" then
        return
    end
    for index, _ in pairs(options) do
        if require("tmux.log.severity").validate(options[index]) then
            M[index] = options[index]
        end
    end
end

return M
