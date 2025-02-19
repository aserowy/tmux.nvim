local opposite_directions = { h = "l", j = "k", k = "j", l = "h" }

local M = {}

function M.is_nvim_border(border)
    return M.winnr() == M.winnr("1" .. border)
end

function M.is_nvim_float()
    return vim.api.nvim_win_get_config(0).relative ~= ""
end

function M.resize(axis, direction, step_size)
    local command = "resize "
    if axis == "x" then
        command = "vertical resize "
    end

    return vim.api.nvim_command(command .. direction .. step_size)
end

function M.swap(direction, count)
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_win_get_buf(current_win)
    local target_winnr = M.winnr(count .. direction)
    local target_win = vim.api.nvim_call_function("win_getid", { target_winnr })
    local target_buf = vim.api.nvim_win_get_buf(target_win)
    vim.api.nvim_win_set_buf(current_win, target_buf)
    vim.api.nvim_win_set_buf(target_win, current_buf)
    M.wincmd(direction, count)
end

function M.wincmd(direction, count)
    return vim.api.nvim_command((count or 1) .. "wincmd " .. direction)
end

function M.winnr(direction)
    return vim.api.nvim_call_function("winnr", { direction })
end

function M.opposite_direction(direction)
    return opposite_directions[direction]
end

return M
