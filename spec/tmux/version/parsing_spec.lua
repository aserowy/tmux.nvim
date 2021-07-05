describe("version parsing", function()
	local parser

	setup(function()
		parser = require("tmux.version.parsing")
	end)

	it("check invalid version validation", function()
		local result = parser.parse_version(nil)
		assert.are.same({}, result)

		result = parser.parse_version("")
		assert.are.same({}, result)

		result = parser.parse_version("a.0a")
		assert.are.same({}, result)

		result = parser.parse_version("0.aa")
		assert.are.same({}, result)

		result = parser.parse_version("0.9ab")
		assert.are.same({}, result)

		result = parser.parse_version("0.9;")
		assert.are.same({}, result)

		result = parser.parse_version("090")
		assert.are.same({}, result)

		result = parser.parse_version("a3.0")
		assert.are.same({}, result)
	end)

	it("check parsing to semantic version (only numbers)", function()
		local result = parser.parse_version("1.0")
		assert.are.same({ major = 1, minor = 0, patch = 0 }, result)

		result = parser.parse_version("1.1")
		assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

		result = parser.parse_version("01.01")
		assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

		result = parser.parse_version("21.21")
		assert.are.same({ major = 21, minor = 21, patch = 0 }, result)

		result = parser.parse_version("1.1a")
		assert.are.same({ major = 1, minor = 1, patch = 1 }, result)

		result = parser.parse_version("1.1c")
		assert.are.same({ major = 1, minor = 1, patch = 3 }, result)

		result = parser.parse_version("1.1z")
		assert.are.same({ major = 1, minor = 1, patch = 26 }, result)
	end)
end)
