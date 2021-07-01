local cfg = require("tmux.configuration")

local log_dir = vim.fn.stdpath("data")

local function write(severity, message)
	local logs = io.open(log_dir .. "/logs/tmuxnvim.log", "a")
	logs:write(severity)
	logs:write(message)
	io.close(logs)
end

local M = {}
function M.debug(message)
	if cfg.options.debug then
		write("debug", message)
	end
end

return M
