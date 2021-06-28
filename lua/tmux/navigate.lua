local vim = vim
local cfg = require("tmux.configuration")
local keymaps = require("tmux.keymaps")
local wrapper = require("tmux.wrapper")

local WINNR_MAX = 999

local opposite_directions = {
	h = 'l',
	j = 'k',
	k = 'j',
	l = 'h',
}

local function winnr(direction)
	return vim.api.nvim_call_function("winnr", { direction })
end

local function wincmd(direction, count)
	return vim.api.nvim_command(count .. "wincmd " .. direction)
end

local function wincmd_next(direction, count)
	local prev_winnr = winnr()
	wincmd(direction, count)
	return winnr() ~= prev_winnr
end

local function wincmd_with_wrap(direction)
	if not wincmd_next(direction, 1) then
		wincmd_next(opposite_directions[direction], WINNR_MAX)
	end
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
		wincmd_with_wrap(direction)
	end
end

local M = {}
function M.setup()
	if cfg.options.navigation.enable_default_keybindings then
		keymaps.register("n", {
			["<C-h>"] = [[<cmd>lua require'tmux'.move_left()<cr>]],
			["<C-j>"] = [[<cmd>lua require'tmux'.move_bottom()<cr>]],
			["<C-k>"] = [[<cmd>lua require'tmux'.move_top()<cr>]],
			["<C-l>"] = [[<cmd>lua require'tmux'.move_right()<cr>]],
		})
	end
end

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
