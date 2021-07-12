local log_dir
local function get_logdir()
	if log_dir == nil then
		log_dir = vim.fn.stdpath("cache") .. "/"
		os.execute("mkdir -p " .. log_dir)
	end
	return log_dir
end

local M = {}
function M.write(sev, message)
	local logs = io.open(get_logdir() .. "tmuxnvim.log", "a")
	logs:write(require("tmux.log.time").now() .. " " .. sev .. "\n")
	logs:write(message .. "\n")
	io.close(logs)
end

return M
