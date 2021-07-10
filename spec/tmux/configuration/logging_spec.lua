local function contains(list, x)
	for _, v in pairs(list) do
		if v == x then
			return true
		end
	end
	return false
end

local function validate(configuration)
	for index, value in ipairs(configuration) do
		if not contains({ "nvim", "file" }, index) then
			return false
		end
		if not contains({ "disabled", "debug", "information", "warning", "error" }, value) then
			return false
		end
	end
	return true
end

describe("configuration logging", function()
	local config

	setup(function()
		config = require("tmux.configuration.logging")
	end)

	it("check invalid values", function()
		config.set(nil)
		local result = require("tmux.configuration.logging")
		assert.are.same(true, validate(result))
	end)
end)
