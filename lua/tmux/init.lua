local cfg = require("tmux.configuration")
local copy = require("tmux.copy")
local navigate = require("tmux.navigate")
local resize = require("tmux.resize")

local M = {
	move_left = navigate.to_left,
	move_bottom = navigate.to_bottom,
	move_top = navigate.to_top,
	move_right = navigate.to_right,

	post_yank = copy.post_yank,
	sync_registers = copy.sync_registers,

	resize_left = resize.to_left,
	resize_bottom = resize.to_bottom,
	resize_top = resize.to_top,
	resize_right = resize.to_right,
}

function M.setup(options)
	cfg.setup(options)

	copy.setup()
	navigate.setup()
	resize.setup()
end

return M
