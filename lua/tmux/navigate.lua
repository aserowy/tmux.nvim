local vim = vim
local cfg = require("tmux.configuration")
local wrapper = require("tmux.wrapper")

local function winnr(direction)
	return vim.api.nvim_call_function("winnr", { direction })
end

local function wincmd(direction)
	return vim.api.nvim_command("wincmd " .. direction)
end

local function has_tmux_target(border)
	if not wrapper.is_tmux then
		return false
	end

	if wrapper.is_zoomed() and cfg.options.navigation.persist_zoom then
		return false
	end

	if cfg.options.navigation.cycle_navigation then
		return true
	end

	return wrapper.has_neighbor(border)
end

local function is_border(border)
	return winnr() == winnr("1" .. border) and has_tmux_target(border)
end

local function navigate_to(direction)
	if is_border(direction) then
		wrapper.change_pane(direction)
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
