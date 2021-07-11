describe("log", function()
	local log

	setup(function()
		log = require("tmux.log")

		require("tmux.configuration.logging").set({
			file = "disabled",
			nvim = "disabled",
			busted = "debug",
		})
	end)

	it("check severity and disables", function()
		log.debug("test")
	end)
end)
