local M = {}
function M.new(value)
	return require("tmux.version.parse").to_version(value)
end

function M.compare(self, relative)
	return require("tmux.version.compare").with(self, relative)
end

return M
