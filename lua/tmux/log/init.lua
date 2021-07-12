local function convert(...)
	return require("tmux.log.convert").to_string(...)
end

local function log(severity, message)
	local converted = convert(message)

	require("tmux.log.channels").log(severity, converted)
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
