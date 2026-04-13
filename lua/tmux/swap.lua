local keymaps = require("tmux.keymaps")
local options = require("tmux.configuration.options")
local layout = require("tmux.layout")
local nvim = require("tmux.wrapper.nvim")
local tmux = require("tmux.wrapper.tmux")
local log = require("tmux.log")

local M = {}

function M.setup()
    if options.swap.enable_default_keybindings then
        keymaps.register("n", {
            ["<C-A-h>"] = [[<cmd>lua require'tmux'.swap_left()<cr>]],
            ["<C-A-j>"] = [[<cmd>lua require'tmux'.swap_bottom()<cr>]],
            ["<C-A-k>"] = [[<cmd>lua require'tmux'.swap_top()<cr>]],
            ["<C-A-l>"] = [[<cmd>lua require'tmux'.swap_right()<cr>]],
        })
    end
end

function M.to(direction)
    local direction_map = { left = "h", right = "l", top = "k", bottom = "j" }
    local res_direction = direction_map[direction]
    if not res_direction then
        log.error("Invalid direction: " .. tostring(res_direction))
        return
    end

    local is_nvim_border = nvim.is_nvim_border(res_direction)
    local persist_zoom = true -- tmux swap-pane when zoomed causes error
    local has_tmux_target = layout.has_tmux_target(res_direction, persist_zoom, options.swap.cycle_navigation)
    if (nvim.is_nvim_float() or is_nvim_border) and has_tmux_target then
        tmux.swap(res_direction)
    elseif is_nvim_border and options.swap.cycle_navigation then
        nvim.swap(nvim.opposite_direction(res_direction), 999)
    elseif not is_nvim_border then
        nvim.swap(res_direction, vim.v.count)
    end
end

function M.to_left()
    M.to("left")
end

function M.to_bottom()
    M.to("bottom")
end

function M.to_top()
    M.to("top")
end

function M.to_right()
    M.to("right")
end

return M
