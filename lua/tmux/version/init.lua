local M = {}
function M.new(value)
	return require("tmux.version.parsing").parse_version(value)
end

return M
