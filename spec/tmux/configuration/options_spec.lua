describe("configuration options", function()
	local config

	setup(function()
		config = require("tmux.configuration.options")
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
				sync_deletes = false,
			},
		})
		result = require("tmux.configuration.options")
		assert.are.same(false, result.copy_sync.sync_deletes)
	end)
end)
