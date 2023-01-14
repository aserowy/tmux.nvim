local layout = require("tmux.layout")
local keymaps = require("tmux.keymaps")
local nvim = require("tmux.wrapper.nvim")
local options = require("tmux.configuration.options")
local tmux = require("tmux.wrapper.tmux")

--return true if there is no other nvim window in the direction of @border
local function is_only_window(border)
    if border == "h" or border == "l" then
        --check for other horizontal window
        return (nvim.winnr("1h") == nvim.winnr("1l"))
    else
        --check for other vertical window
        return (nvim.winnr("1j") == nvim.winnr("1k"))
    end
end

local function is_tmux_target(border)
    if not tmux.is_tmux then
        return false
    end

    return not layout.is_border(border) or is_only_window(border)
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
    local is_border = nvim.is_nvim_border("l")
    if is_border and is_tmux_target("l") then
        tmux.resize("h", options.resize.resize_step_x)
    elseif is_border then
        nvim.resize("x", "+", options.resize.resize_step_x)
    else
        vim.fn.win_move_separator(0, -options.resize.resize_step_x)
    end
end

function M.to_bottom()
    local is_border = nvim.is_nvim_border("j")
    if is_border and is_tmux_target("j") then
        tmux.resize("j", options.resize.resize_step_y)
    elseif is_border then
        nvim.resize("y", "-", options.resize.resize_step_y)
    else
        vim.fn.win_move_statusline(0, options.resize.resize_step_y)
    end
end

function M.to_top()
    local is_border = nvim.is_nvim_border("j")
    if is_border and is_tmux_target("j") then
        tmux.resize("k", options.resize.resize_step_y)
    elseif is_border then
        nvim.resize("y", "+", options.resize.resize_step_y)
    else
        vim.fn.win_move_statusline(0, -options.resize.resize_step_y)
    end
end

function M.to_right()
    local is_border = nvim.is_nvim_border("l")
    if is_border and is_tmux_target("l") then
        tmux.resize("l", options.resize.resize_step_x)
    elseif is_border then
        nvim.resize("x", "-", options.resize.resize_step_x)
    else
        vim.fn.win_move_separator(0, options.resize.resize_step_x)
    end
end

return M
