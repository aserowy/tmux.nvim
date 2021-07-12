describe("log channels", function()
	local channels

	setup(function()
		channels = require("tmux.log.channels")
	end)

	it("check add channel", function()
		assert.are.same({}, channels.current)
		channels.add("file", nil)
		assert.are.same({ file = nil }, channels.current)

		local test_channel = require("tmux.log.channels")
		assert.are.same({ file = nil }, test_channel.current)
	end)

	it("check ignoring invalid channels", function()
		require("tmux.log.severity").check = function(_, _)
			return true
		end

		local call_count = 0
		local function increment()
			call_count = call_count + 1
		end
		channels.add(nil, increment)
		channels.log("warning", "prefix", "message")
		assert.are.same(0, call_count)

		channels.add(1, increment)
		channels.log("warning", "prefix", "message")
		assert.are.same(0, call_count)

		channels.add("test3", nil)
		channels.log("warning", "prefix", "message")
		assert.are.same(0, call_count)

		channels.add("test4", "test")
		channels.log("warning", "prefix", "message")
		assert.are.same(0, call_count)

		channels.add("test5", 0)
		channels.log("warning", "prefix", "message")
		assert.are.same(0, call_count)

		channels.add("test6", {})
		channels.log("warning", "prefix", "message")
		assert.are.same(0, call_count)
	end)

	it("check log channels by severity", function()
		require("tmux.log.severity").check = function(_, channel)
			return channel ~= "test1"
		end

		local call_count = 0
		local function increment()
			call_count = call_count + 1
		end

		channels.add("test1", increment)
		channels.add("test2", increment)
		channels.add("test3", increment)
		channels.add("test4", increment)
		channels.add("test5", increment)

		channels.log("warning", "prefix", "message")

		assert.are.same(4, call_count)
	end)
end)
