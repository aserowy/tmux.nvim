local log = require("tmux.log")

local function log_mock(...)
	print(...)
end

local M = {}
function M.setup()
	log.debug = function(message)
		log_mock("debug", message)
	end

	log.warning = function(message)
		log_mock("warning", message)
	end

	log.error = function(message)
		log_mock("error", message)
	end
end

return M
