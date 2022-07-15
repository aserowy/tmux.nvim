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
                sync_clipboard = true,
                sync_registers = true,
                sync_deletes = true,
                ignore_buffers = { empty = false },
                sync_unnamed = true,
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

        config.set({
            copy_sync = {
                ignore_buffers = "test",
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same({ empty = false }, result.copy_sync.ignore_buffers)
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
                sync_registers = false,
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same(false, result.copy_sync.sync_registers)

        config.set({
            copy_sync = {
                sync_deletes = false,
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same(false, result.copy_sync.sync_deletes)

        config.set({
            copy_sync = {
                sync_unnamed = false,
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same(false, result.copy_sync.sync_unnamed)

        config.set({
            copy_sync = {
                ignore_buffers = { empty = true },
            },
        })
        result = require("tmux.configuration.options")
        assert.are.same({ empty = true }, result.copy_sync.ignore_buffers)

        config.set({
            copy_sync = {
                ignore_buffers = { tmp = true },
            },
        })
        result = require("tmux.configuration.options")
        local expected = { empty = true, tmp = true }
        assert.are.same(expected, result.copy_sync.ignore_buffers)
    end)
end)
