local keymaps = require("tmux.keymaps")
local navigate = require("tmux.navigation.navigate")
local options = require("tmux.configuration.options")
local log = require("tmux.log")

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
    navigate.to("h")
end

function M.to_bottom()
    navigate.to("j")
end

function M.to_top()
    navigate.to("k")
end

function M.to_right()
    navigate.to("l")
end

function M.to(direction)
    local direction_map = { left = "h", right = "l", top = "k", bottom = "j" }
    local res_direction = direction_map[direction]
    if res_direction then
        navigate.to(res_direction)
    else
        log.error("Invalid direction: " .. tostring(direction))
    end
end

function M.next_window()
    navigate.window("n")
end

function M.previous_window()
    navigate.window("p")
end

return M
