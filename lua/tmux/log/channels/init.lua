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

function M.log(sev, prefix, message)
	for key, value in pairs(M.current) do
		--TODO: resolve severity for key and inject as barrier, sev
		if severity.check(sev, key) then
			value(prefix, message)
		end
	end
end

return M
