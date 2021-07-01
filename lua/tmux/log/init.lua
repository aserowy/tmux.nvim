local cfg = require("tmux.configuration")

local log_dir = vim.fn.stdpath("data") .. "/logs/"

local function convert(...)
	return require("tmux.log.convert").to_string(...)
end

local function write(severity, message)
	os.execute("mkdir -p " .. log_dir)

	local logs = io.open(log_dir .. "tmuxnvim.log", "a")
	logs:write(os.date("%c") .. "\t" .. severity .. "\n")
	logs:write(convert(message) .. "\n")
	io.close(logs)
end

local M = {}
function M.debug(message)
	if cfg.options.debug then
		write("debug", message)
	end
end

return M
