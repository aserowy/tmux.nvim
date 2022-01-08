local execute = vim.api.nvim_command
local fn = vim.fn

local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
    execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
    execute("packadd packer.nvim")
end

require("packer").startup(function(use)
    use("wbthomason/packer.nvim")

    use({
        "rcarriga/nvim-notify",
        config = function()
            vim.notify = require("notify")
        end,
    })

    use({
        "kyazdani42/nvim-tree.lua",
    })

    use({
        "/workspace/",
        config = function()
            require("tmux").setup({
                copy_sync = {
                    enable = true,
                    ignore_buffers = { buffer0 = true },
                    redirect_to_clipboard = true,
                },
                navigation = {
                    cycle_navigation = false,
                    enable_default_keybindings = true,
                    persist_zoom = true,
                },
                resize = {
                    enable_default_keybindings = true,
                },
            }, {
                file = "debug",
                notify = "debug",
            })
        end,
    })
end)

local opts = {
    nowait = true,
    silent = true,
    noremap = true,
}

vim.api.nvim_set_keymap("n", "<C-e>", [[<cmd>lua require("nvim-tree").find_file(true)<cr> ]], opts)
