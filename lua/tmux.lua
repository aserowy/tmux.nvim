local navigate = require("tmux.navigate")
local resize = require("tmux.resize")

local M = {}
M.setup = function(options)
	print(options)
end

M.move_left = function()
	navigate.to("h")
end

M.move_down = function()
	navigate.to("j")
end

M.move_top = function()
	navigate.to("k")
end

M.move_right = function()
	navigate.to("l")
end

M.resize_left = function()
	resize.to("h")
end

M.resize_down = function()
	resize.to("j")
end

M.resize_top = function()
	resize.to("k")
end

M.resize_right = function()
	resize.to("l")
end

return M
