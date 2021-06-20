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

local function navigate_to(direction)
	if is_border(direction) then
		tmux.change_pane(direction)
	else
		wincmd(direction)
	end
end

local M = {}
function M.to_left()
	navigate_to("h")
end

function M.to_bottom()
	navigate_to("j")
end

function M.to_top()
	navigate_to("k")
end

function M.to_right()
	navigate_to("l")
end

return M
