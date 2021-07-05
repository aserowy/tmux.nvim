describe("version parsing", function()
	local version

	setup(function()
		version = require("tmux.version")
	end)

	it("check invalid version validation", function()
		local result = version.new(nil)
		assert.are.same({}, result)

		result = version.new("")
		assert.are.same({}, result)

		result = version.new("a.0a")
		assert.are.same({}, result)

		result = version.new("0.aa")
		assert.are.same({}, result)

		result = version.new("0.9ab")
		assert.are.same({}, result)

		result = version.new("090")
		assert.are.same({}, result)

		result = version.new("a3.0")
		assert.are.same({}, result)
	end)

	it("check parsing to semantic version (only numbers)", function()
		local result = version.new("1.0")
		assert.are.same({ major = 1, minor = 0, patch = 0 }, result)

		result = version.new("1.1")
		assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

		result = version.new("01.01")
		assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

		result = version.new("21.21")
		assert.are.same({ major = 21, minor = 21, patch = 0 }, result)

		result = version.new("1.1a")
		assert.are.same({ major = 1, minor = 1, patch = 1 }, result)

		result = version.new("1.1c")
		assert.are.same({ major = 1, minor = 1, patch = 3 }, result)

		result = version.new("1.1z")
		assert.are.same({ major = 1, minor = 1, patch = 26 }, result)
	end)
end)
