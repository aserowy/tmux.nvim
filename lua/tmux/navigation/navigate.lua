local layout = require("tmux.layout")
local log = require("tmux.log")
local nvim = require("tmux.wrapper.nvim")
local options = require("tmux.configuration.options")
local tmux = require("tmux.wrapper.tmux")

local M = {}

-- wincmd never enters floating windows, so remember the float we left to be
-- able to go back into it with the opposite direction
local float_exit = nil

local function go_back_into_float(direction)
    local exit = float_exit
    float_exit = nil
    if exit == nil or exit.direction ~= direction or vim.fn.getcmdwintype() ~= "" then
        return false
    end
    if vim.api.nvim_get_current_win() ~= exit.landed or not vim.api.nvim_win_is_valid(exit.float) then
        return false
    end
    vim.api.nvim_set_current_win(exit.float)
    return true
end

function M.window(direction)
    log.debug("navigate.window: " .. direction)
    if options.navigation.cycle_navigation or layout.has_tmux_window(direction) then
        tmux.select_window(direction)
    end
end

function M.to(direction)
    log.debug("navigate_to: " .. direction)

    if go_back_into_float(direction) then
        return
    end

    local is_nvim_float = nvim.is_nvim_float()
    local is_nvim_border = nvim.is_nvim_border(direction)
    -- only ask tmux (which spawns a process) when we could actually leave nvim
    local has_tmux_target = (is_nvim_float or is_nvim_border)
        and layout.has_tmux_target(direction, options.navigation.persist_zoom, options.navigation.cycle_navigation)
    if has_tmux_target then
        tmux.change_pane(direction)
    elseif vim.fn.getcmdwintype() == "" then -- if not in command mode
        local from = is_nvim_float and vim.api.nvim_get_current_win()
        if is_nvim_border and options.navigation.cycle_navigation then
            nvim.wincmd(nvim.opposite_direction(direction), 999)
        elseif not is_nvim_border then
            nvim.wincmd(direction, vim.v.count)
        end
        if from and vim.api.nvim_get_current_win() ~= from then
            float_exit = {
                float = from,
                landed = vim.api.nvim_get_current_win(),
                direction = nvim.opposite_direction(direction),
            }
        end
    end
end

return M
