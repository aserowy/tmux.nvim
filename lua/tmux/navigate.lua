local vim = vim

local keymaps = require("tmux.keymaps")
local layout = require("tmux.layout")
local log = require("tmux.log")
local options = require("tmux.configuration.options")
local tmux = require("tmux.wrapper.tmux")

local opposite_directions = {
    h = "l",
    j = "k",
    k = "j",
    l = "h",
}

local function winnr(direction)
    return vim.api.nvim_call_function("winnr", { direction })
end

local function is_nvim_border(border)
    return winnr() == winnr("1" .. border)
end

local function wincmd(direction, count)
    return vim.api.nvim_command((count or 1) .. "wincmd " .. direction)
end

local function wincmd_with_cycle(direction)
    if is_nvim_border(direction) then
        wincmd(opposite_directions[direction], 999)
    else
        wincmd(direction)
    end
end

local function has_tmux_target(direction)
    if not tmux.is_tmux then
        return false
    end
    if tmux.is_zoomed() and options.navigation.persist_zoom then
        return false
    end
    if not layout.is_border(direction) then
        return true
    end
    return options.navigation.cycle_navigation
end

local function navigate_to(direction)
    log.debug("navigate_to: " .. direction)

    if is_nvim_border(direction) and has_tmux_target(direction) then
        tmux.change_pane(direction)
    elseif is_nvim_border(direction) and options.navigation.cycle_navigation then
        wincmd_with_cycle(direction)
    else
        wincmd(direction)
    end
end

local M = {}
function M.setup()
    if options.navigation.enable_default_keybindings then
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
