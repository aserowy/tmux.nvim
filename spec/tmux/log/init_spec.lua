insulate("log setup", function()
    it("check default channel registration", function()
        require("tmux.log").setup()

        local channels = require("tmux.log.channels")
        assert.is_true(channels.current["file"] ~= nil)
    end)
end)

describe("log", function()
    local log
    local message = ""

    setup(function()
        log = require("tmux.log")

        require("tmux.log.time").now = function()
            return "1234"
        end

        require("tmux.configuration.logging").set({
            file = "disabled",
            nvim = "disabled",
        })

        require("tmux.log.channels").add("busted", function(sev, msg)
            message = sev .. " - " .. msg
        end)
    end)

    it("check severity and disables", function()
        require("tmux.configuration.logging").set({
            busted = "disabled",
        })

        log.debug("test")
        assert.are.same("", message)
        log.information("test")
        assert.are.same("", message)
        log.warning("test")
        assert.are.same("", message)
        log.error("test")
        assert.are.same("", message)

        require("tmux.configuration.logging").set({
            busted = "debug",
        })
        message = ""

        log.debug("test")
        assert.are.same("debug - test", message)
        log.information("test")
        assert.are.same("information - test", message)
        log.warning("test")
        assert.are.same("warning - test", message)
        log.error("test")
        assert.are.same("error - test", message)

        require("tmux.configuration.logging").set({
            busted = "information",
        })
        message = ""

        log.debug("test")
        assert.are.same("", message)
        log.information("test")
        assert.are.same("information - test", message)
        log.warning("test")
        assert.are.same("warning - test", message)
        log.error("test")
        assert.are.same("error - test", message)

        require("tmux.configuration.logging").set({
            busted = "warning",
        })
        message = ""

        log.debug("test")
        assert.are.same("", message)
        log.information("test")
        assert.are.same("", message)
        log.warning("test")
        assert.are.same("warning - test", message)
        log.error("test")
        assert.are.same("error - test", message)

        require("tmux.configuration.logging").set({
            busted = "error",
        })
        message = ""

        log.debug("test")
        assert.are.same("", message)
        log.information("test")
        assert.are.same("", message)
        log.warning("test")
        assert.are.same("", message)
        log.error("test")
        assert.are.same("error - test", message)
    end)

    it("check object arguments", function()
        require("tmux.configuration.logging").set({
            busted = "debug",
        })
        message = ""

        log.debug("test: ", nil)
        assert.are.same("debug - test: ", message)

        log.debug("test: ", true)
        assert.are.same("debug - test: true", message)

        log.information("test: ", true)
        assert.are.same("information - test: true", message)

        log.warning("test: ", true)
        assert.are.same("warning - test: true", message)

        log.error("test: ", true)
        assert.are.same("error - test: true", message)
    end)
end)
