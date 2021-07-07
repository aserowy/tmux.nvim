local options = require("tmux.configuration.options")

local log_dir
local function get_logdir()
	if log_dir == nil then
		log_dir = vim.fn.stdpath("cache") .. "/"
	end
	return log_dir
end

local function convert(...)
	return require("tmux.log.convert").to_string(...)
end

local function write(severity, message)
	os.execute("mkdir -p " .. get_logdir())

	local logs = io.open(get_logdir() .. "tmuxnvim.log", "a")
	logs:write(os.date("%c") .. "\t" .. severity .. "\n")
	logs:write(convert(message) .. "\n")
	io.close(logs)
end

local function log(severity, message)
	if options.logging then
		write(severity, message)
	end
end

local M = {}
function M.debug(message)
	log("debug", message)
end

function M.warning(message)
	log("warning", message)
end

function M.error(message)
	log("error", message)
end

return M
