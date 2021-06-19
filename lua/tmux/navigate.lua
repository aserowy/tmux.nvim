local vim = vim
local tmux = require("tmux.wrapper")

local function winnr(direction)
	return vim.api.nvim_call_function("winnr", { direction })
end

local function wincmd(direction)
	return vim.api.nvim_command("wincmd " .. direction)
end

local function is_tmux_target(border)
	return tmux.is_tmux and tmux.has_neighbor(border)
end

local function is_border(border)
	return winnr() == winnr("1" .. border) and is_tmux_target(border)
end

local M = {}
M.to = function(direction)
	if is_border(direction) then
		tmux.change_pane(direction)
	else
		wincmd(direction)
	end
end

return M
