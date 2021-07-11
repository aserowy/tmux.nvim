local log_options = require("tmux.configuration.logging")

local function convert(...)
	return require("tmux.log.convert").to_string(...)
end

local function write(severity, message)
	local prefix = os.date("%c") .. "\t" .. severity
	local converted = convert(message)
	require("tmux.log.channel.file").write(prefix, converted)
end

local function log(severity, message)
	if log_options.logging then
		write(severity, message)
	end
end

local M = {}
function M.debug(message)
	log("debug", message)
end

function M.information(message)
	log("information", message)
end

function M.warning(message)
	log("warning", message)
end

function M.error(message)
	log("error", message)
end

return M
