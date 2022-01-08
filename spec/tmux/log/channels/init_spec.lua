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

        channels.add("file", nil)
        assert.are.same({ file = nil }, test_channel.current)

        channels.add("test", nil)
        assert.are.same({ file = nil, test = nil }, test_channel.current)
    end)

    it("check channels", function()
        local called = 0
        channels.add("test", function()
            called = called + 1
        end)

        called = 0
        channels.log("warning", "message")
        assert.are.same(0, called)

        require("tmux.configuration.logging").set({
            test = "warning",
        })

        called = 0
        channels.log("warning", "message")
        assert.are.same(1, called)
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
        channels.log("warning", "message")
        assert.are.same(0, call_count)

        channels.add(1, increment)
        channels.log("warning", "message")
        assert.are.same(0, call_count)

        channels.add("test3", nil)
        channels.log("warning", "message")
        assert.are.same(0, call_count)

        channels.add("test4", "test")
        channels.log("warning", "message")
        assert.are.same(0, call_count)

        channels.add("test5", 0)
        channels.log("warning", "message")
        assert.are.same(0, call_count)

        channels.add("test6", {})
        channels.log("warning", "message")
        assert.are.same(0, call_count)
    end)

    it("check log channels by severity", function()
        local invalidate_first = true
        require("tmux.log.severity").check = function(_, _)
            if invalidate_first then
                invalidate_first = false
                return false
            end
            return true
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

        channels.log("warning", "message")

        assert.are.same(4, call_count)
    end)

    it("failing channel does not throw exception", function()
        local logged = false
        channels.add("log", function(_, _)
            logged = true
        end)

        channels.add("failing", function(_, _)
            error("failed")
        end)

        channels.log("debug", "message")

        assert.is_true(logged)
    end)
end)
