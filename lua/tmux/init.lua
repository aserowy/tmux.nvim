local navigate = require("tmux.navigate")
local cfg = require("tmux.configuration")
local resize = require("tmux.resize")

local M = {
	setup = cfg.setup,

	move_left = navigate.to_left,
	move_bottom = navigate.to_bottom,
	move_top = navigate.to_top,
	move_right = navigate.to_right,

	resize_left = resize.to_left,
	resize_bottom = resize.to_bottom,
	resize_top = resize.to_top,
	resize_right = resize.to_right,
}

return M
