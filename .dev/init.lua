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
        "~/src/",
        config = function()
            require("tmux").setup({
                copy_sync = {
                    enable = true,
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
            })
        end,
    })
end)