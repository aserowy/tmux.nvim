describe("configuration options", function()
    local config

    setup(function()
        config = require("tmux.configuration.options")
    end)

    it("check default values", function()
        local defaults = {
            copy_sync = {
                enable = false,
                redirect_to_clipboard = false,
                register_offset = 0,
                sync_deletes = true,
                sync_clipboard = true,
            },
            navigation = {
                cycle_navigation = true,
                enable_default_keybindings = false,
                persist_zoom = false,
            },
            resize = {
                enable_default_keybindings = false,
                resize_step_x = 1,
                resize_step_y = 1,
            },
        }
        for key, _ in pairs(defaults) do
            assert.are.same(defaults[key], config[key])
        end
    end)

    it("check invalid values", function()
        config.set(nil)
        local result = require("tmux.configuration.options")
        assert.are.same(1, result.resize.resize_step_x)

        config.set("")
        result = require("tmux.configuration.options")
        assert.are.same(1, result.resize.resize_step_x)

        config.set({})
        result = require("tmux.configuration.options")
        assert.are.same(1, result.resize.resize_step_x)

        config.set({
            test = "blub",
        })
        result = require("tmux.configuration.options")
        assert.are.same(1, result.resize.resize_step_x)

        config.set({
            copy_sync = {
                enable = "blub",
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same(false, result.copy_sync.enable)
    end)

    it("check valid value mappings", function()
        config.set({
            resize = {
                resize_step_x = 5,
            },
        })
        local result = require("tmux.configuration.options")
        assert.are.same(5, result.resize.resize_step_x)

        config.set({
            copy_sync = {
                sync_clipboard = false,
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same(false, result.copy_sync.sync_clipboard)

        config.set({
            copy_sync = {
                sync_deletes = false,
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same(false, result.copy_sync.sync_deletes)
    end)
end)
