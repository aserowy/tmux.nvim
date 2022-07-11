local layout = require("tmux.layout")
local config = require("tmux.configuration")
local tmux = require("tmux.tmux")

local options = config.options

local M = {}

local opposite_directions = {
    h = "l",
    j = "k",
    k = "j",
    l = "h",
}

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
    return options.navigation.cycle_navigation and not layout.is_border(opposite_directions[direction])
end

local function is_nvim_border(border)
    return vim.fn.winnr() == vim.fn.winnr("1" .. border)
end

local function nav_to(direction)
    local is_border = is_nvim_border(direction)
    if is_border and has_tmux_target(direction) then
        tmux.change_pane(direction)
    elseif is_border and options.navigation.cycle_navigation then
        vim.cmd("999wincmd " .. opposite_directions[direction])
    elseif not is_border then
        vim.cmd("1wincmd " .. direction)
    end
end

function M.move_left()
    nav_to("h")
end

function M.move_bottom()
    nav_to("j")
end

function M.move_top()
    nav_to("k")
end

function M.move_right()
    nav_to("l")
end


local function is_only_window()
    return (vim.fn.winnr("1h") == vim.fn.winnr("1l")) and (vim.fn.winnr("1j") == vim.fn.winnr("1k"))
end

local function is_tmux_target(border)
    if not tmux.is_tmux then
        return false
    end

    return not layout.is_border(border) or is_only_window()
end

function M.resize_left()
    local is_border = is_nvim_border("l")
    if is_border and is_tmux_target("l") then
        tmux.resize("h", options.resize.resize_step_x)
    elseif is_border then
        vim.cmd('vertical resize -'..options.resize.resize_step_x)
    else
        vim.cmd('vertical resize +'..options.resize.resize_step_x)
    end
end

function M.resize_bottom()
    local is_border = is_nvim_border("j")
    if is_border and is_tmux_target("j") then
        tmux.resize("j", options.resize.resize_step_y)
    elseif is_border and vim.fn.winnr() ~= vim.fn.winnr("1k") then
        vim.cmd('resize -'..options.resize.resize_step_y)
    else
        vim.cmd('resize +'..options.resize.resize_step_y)
    end
end

function M.resize_top()
    local is_border = is_nvim_border("j")
    if is_border and is_tmux_target("j") then
        tmux.resize("k", options.resize.resize_step_y)
    elseif is_border then
        vim.cmd('resize -'..options.resize.resize_step_y)
    else
        vim.cmd('resize +'..options.resize.resize_step_y)
    end
end

function M.resize_right()
    local is_border = is_nvim_border("l")
    if is_border and is_tmux_target("l") then
        tmux.resize("l", options.resize.resize_step_x)
    elseif is_border then
        vim.cmd('vertical resize -'..options.resize.resize_step_x)
    else
        vim.cmd('vertical resize +'..options.resize.resize_step_x)
    end
end

function M.setup(user_options)
    tmux.setup()
    config.setup(user_options)

    local copy = require("tmux.copy")
    copy.setup()

    M.post_yank = copy.post_yank
    M.sync_registers = copy.sync_registers

    local function nmap(l, r)
        vim.keymap.set('n', l, r, { nowait = true, silent = true })
    end

    if options.resize.enable_default_keybindings then
        nmap('<A-h>', M.resize_left)
        nmap('<A-j>', M.resize_bottom)
        nmap('<A-k>', M.resize_top)
        nmap('<A-l>', M.resize_right)
    end

    if options.navigation.enable_default_keybindings then
        nmap('<C-h>', M.move_left)
        nmap('<C-j>', M.move_bottom)
        nmap('<C-k>', M.move_top)
        nmap('<C-l>', M.move_right)
    end
end

return M
