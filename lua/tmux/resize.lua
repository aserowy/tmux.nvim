local vim = vim
local wrapper = require("tmux.wrapper")

local function winnr(direction)
	return vim.api.nvim_call_function("winnr", { direction })
end

local function wincmd(direction)
	return vim.api.nvim_command("wincmd " .. direction)
end

local function is_only_window()
	return (winnr("1h") == winnr("1l")) == (winnr("1j") == winnr("1k"))
end

local function is_tmux_target(border)
	return wrapper.is_tmux and wrapper.has_neighbor(border) or is_only_window()
end

local M = {}
function M.to_left()
	local is_border = winnr() == winnr("1l")
	if is_border and is_tmux_target("l") then
		wrapper.resize("h")
	elseif is_border then
		wincmd(">")
	else
		wincmd("<")
	end
end

function M.to_bottom()
	local is_border = winnr() == winnr("1j")
	if is_border and is_tmux_target("j") then
		wrapper.resize("j")
	elseif is_border and winnr() ~= winnr("1k") then
		wincmd("-")
	else
		wincmd("+")
	end
end

function M.to_top()
	local is_border = winnr() == winnr("1j")
	if is_border and is_tmux_target("j") then
		wrapper.resize("k")
	elseif is_border then
		wincmd("+")
	else
		wincmd("-")
	end
end

function M.to_right()
	local is_border = winnr() == winnr("1l")
	if is_border and is_tmux_target("l") then
		wrapper.resize("l")
	elseif is_border then
		wincmd("<")
	else
		wincmd(">")
	end
end

return M
