local function contains(list, x)
    for _, v in pairs(list) do
        if v == x then
            return true
        end
    end
    return false
end

local function validate(configuration)
    for index, value in pairs(configuration) do
        if index ~= "set" then
            if not contains({ "disabled", "debug", "information", "warning", "error" }, value) then
                return false
            end
        end
    end
    return true
end

describe("configuration logging", function()
    local config

    setup(function()
        config = require("tmux.configuration.logging")
    end)

    it("check default values", function()
        local defaults = {
            file = "warning",
            notify = "warning",
        }
        for key, _ in pairs(defaults) do
            assert.are.same(defaults[key], config[key])
        end
    end)

    it("check invalid values", function()
        config.set(nil)
        local result = require("tmux.configuration.logging")
        assert.are.same(true, validate(result))

        config.set("")
        result = require("tmux.configuration.logging")
        assert.are.same(true, validate(result))

        config.set({})
        result = require("tmux.configuration.logging")
        assert.are.same(true, validate(result))

        config.set({
            test = "blub",
        })
        result = require("tmux.configuration.logging")
        assert.are.same(true, validate(result))

        config.set({
            file = "blub",
        })
        result = require("tmux.configuration.logging")
        assert.are.same(true, validate(result))
    end)

    it("check valid value mappings", function()
        config.set({
            nvim = "disabled",
        })
        local result = require("tmux.configuration.logging")
        assert.are.same("disabled", result.nvim)
        assert.are.same(true, validate(result))
    end)

    it("check adding options for new channels", function()
        config.set({
            test_channel = "error",
        })
        local result = require("tmux.configuration.logging")
        assert.are.same("error", result.test_channel)
        assert.are.same(true, validate(result))
    end)
end)
