local function write(severity, message)
    local logs = io.open('file.txt}','a')
logs:write('Hello world. ')
logs:write('This is different')
io.close(logs)
end

local M = {}
function M.debug(message)
    
end

return M
