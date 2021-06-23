local vim = vim
local cfg = require("tmux.configuration")
local keymaps = require("tmux.keymaps")
local wrapper = require("tmux.wrapper")

local function winnr(direction)
	return vim.api.nvim_call_function("winnr", { direction })
end

local function resize(axis, direction, step_size)
    local command = "resize "
    if axis == "x" then
        command = "vertical resize "
    end

	return vim.api.nvim_command(command .. direction .. step_size)
end

local function is_only_window()
	return (winnr("1h") == winnr("1l")) and (winnr("1j") == winnr("1k"))
end

local function is_tmux_target(border)
	return wrapper.is_tmux and wrapper.has_neighbor(border) or is_only_window()
end

local M = {}
function M.setup()
	if cfg.options.resize.enable_default_keybindings then
		keymaps.register("n", {
			["<A-h>"] = [[<cmd>lua require'tmux'.resize_left()<cr>]],
			["<A-j>"] = [[<cmd>lua require'tmux'.resize_bottom()<cr>]],
			["<A-k>"] = [[<cmd>lua require'tmux'.resize_top()<cr>]],
			["<A-l>"] = [[<cmd>lua require'tmux'.resize_right()<cr>]],
		})
	end
end

function M.to_left()
	local is_border = winnr() == winnr("1l")
	if is_border and is_tmux_target("l") then
		wrapper.resize("h")
	elseif is_border then
		resize("x", "+", cfg.options.resize.resize_step_x)
	else
		resize("x", "-", cfg.options.resize.resize_step_x)
	end
end

function M.to_bottom()
	local is_border = winnr() == winnr("1j")
	if is_border and is_tmux_target("j") then
		wrapper.resize("j")
	elseif is_border and winnr() ~= winnr("1k") then
		resize("y", "-", cfg.options.resize.resize_step_y)
	else
		resize("y", "+", cfg.options.resize.resize_step_y)
	end
end

function M.to_top()
	local is_border = winnr() == winnr("1j")
	if is_border and is_tmux_target("j") then
		wrapper.resize("k")
	elseif is_border then
		resize("y", "+", cfg.options.resize.resize_step_y)
	else
		resize("y", "-", cfg.options.resize.resize_step_y)
	end
end

function M.to_right()
	local is_border = winnr() == winnr("1l")
	if is_border and is_tmux_target("l") then
		wrapper.resize("l")
	elseif is_border then
		resize("x", "-", cfg.options.resize.resize_step_x)
	else
		resize("x", "+", cfg.options.resize.resize_step_x)
	end
end

return M
