local options = require("tmux.configuration.options")

local function convert(...)
	return require("tmux.log.convert").to_string(...)
end

local function write(severity, message)
	local prefix = os.date("%c") .. "\t" .. severity
	local converted = convert(message)
	require("tmux.log.channel_file").write(prefix, converted)
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
