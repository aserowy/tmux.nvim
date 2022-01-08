describe("log channel notify", function()
    local notify_channel

    local last_notification = {}
    local function notify_mock(message, severity, options)
        last_notification = {
            message = message,
            severity = severity,
            options = options,
        }
    end

    setup(function()
        notify_channel = require("tmux.log.channels.notify").create(notify_mock, {
            debug = "DEBUG",
            information = "INFO",
        })
    end)

    it("ctor creates not same items", function()
        local channel_1 = require("tmux.log.channels.notify").create({}, {})
        local channel_2 = require("tmux.log.channels.notify").create({}, {})
        assert.are_not.same(channel_1, channel_2)
    end)

    it("invalid calls result in no notification", function()
        notify_channel.write(nil, "message")
        assert.are.same({}, last_notification)

        notify_channel.write("", "message")
        assert.are.same({}, last_notification)

        notify_channel.write("debug", nil)
        assert.are.same({}, last_notification)

        notify_channel.write("debug", "")
        assert.are.same({}, last_notification)
    end)

    it("valid calls result in notifications", function()
        notify_channel.write("debug", "message")
        assert.are.same("DEBUG", last_notification.severity)
        assert.are.same("message", last_notification.message)

        notify_channel.write("information", "test_message")
        assert.are.same("INFO", last_notification.severity)
        assert.are.same("test_message", last_notification.message)
    end)
end)
