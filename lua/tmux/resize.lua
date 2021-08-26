local vim = vim

local layout = require("tmux.layout")
local keymaps = require("tmux.keymaps")
local options = require("tmux.configuration.options")
local tmux = require("tmux.wrapper.tmux")

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
    return tmux.is_tmux and not layout.is_border(border) or is_only_window()
end

local M = {}
function M.setup()
    if options.resize.enable_default_keybindings then
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
        tmux.resize("h")
    elseif is_border then
        resize("x", "+", options.resize.resize_step_x)
    else
        resize("x", "-", options.resize.resize_step_x)
    end
end

function M.to_bottom()
    local is_border = winnr() == winnr("1j")
    if is_border and is_tmux_target("j") then
        tmux.resize("j")
    elseif is_border and winnr() ~= winnr("1k") then
        resize("y", "-", options.resize.resize_step_y)
    else
        resize("y", "+", options.resize.resize_step_y)
    end
end

function M.to_top()
    local is_border = winnr() == winnr("1j")
    if is_border and is_tmux_target("j") then
        tmux.resize("k")
    elseif is_border then
        resize("y", "+", options.resize.resize_step_y)
    else
        resize("y", "-", options.resize.resize_step_y)
    end
end

function M.to_right()
    local is_border = winnr() == winnr("1l")
    if is_border and is_tmux_target("l") then
        tmux.resize("l")
    elseif is_border then
        resize("x", "-", options.resize.resize_step_x)
    else
        resize("x", "+", options.resize.resize_step_x)
    end
end

return M
