---@diagnostic disable: duplicate-set-field
describe("utils.has_tmux_target", function()
    local utils
    local layout
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        utils = require("tmux.utils")
        layout = require("tmux.layout")
        tmux = require("tmux.wrapper.tmux")
    end)

    it("check is_tmux false", function()
        tmux.is_tmux = false

        local result = utils.has_tmux_target("h", false, true)
        assert.is_false(result)

        result = utils.has_tmux_target("j", false, true)
        assert.is_false(result)

        result = utils.has_tmux_target("k", false, true)
        assert.is_false(result)

        result = utils.has_tmux_target("l", false, true)
        assert.is_false(result)
    end)

    it("check is_zoomed true", function()
        tmux.is_tmux = true
        tmux.is_zoomed = function()
            return true
        end
        layout.is_border = function(_)
            return false
        end

        local result = utils.has_tmux_target("h", true, true)
        assert.is_false(result)

        result = utils.has_tmux_target("j", true, true)
        assert.is_false(result)

        result = utils.has_tmux_target("k", true, true)
        assert.is_false(result)

        result = utils.has_tmux_target("l", true, true)
        assert.is_false(result)

        result = utils.has_tmux_target("h", false, true)
        assert.is_true(result)

        result = utils.has_tmux_target("j", false, true)
        assert.is_true(result)

        result = utils.has_tmux_target("k", false, true)
        assert.is_true(result)

        result = utils.has_tmux_target("l", false, true)
        assert.is_true(result)
    end)

    it("check is_border false", function()
        tmux.is_tmux = true
        tmux.is_zoomed = function()
            return false
        end
        layout.is_border = function(_)
            return false
        end

        local result = utils.has_tmux_target("h", false, true)
        assert.is_true(result)

        result = utils.has_tmux_target("j", false, true)
        assert.is_true(result)

        result = utils.has_tmux_target("k", false, true)
        assert.is_true(result)

        result = utils.has_tmux_target("l", false, true)
        assert.is_true(result)
    end)

    it("check is_border true", function()
        tmux.is_tmux = true
        tmux.is_zoomed = function()
            return false
        end
        layout.is_border = function(_)
            return true
        end

        local result = utils.has_tmux_target("h", false, false)
        assert.is_false(result)

        result = utils.has_tmux_target("j", false, false)
        assert.is_false(result)

        result = utils.has_tmux_target("k", false, false)
        assert.is_false(result)

        result = utils.has_tmux_target("l", false, false)
        assert.is_false(result)
    end)

    it("check cycle_navigation true", function()
        tmux.is_tmux = true
        tmux.is_zoomed = function()
            return false
        end
        layout.is_border = function(direction)
            return direction == "h"
        end

        local result = utils.has_tmux_target("h", false, false)
        assert.is_false(result)

        result = utils.has_tmux_target("h", false, true)
        assert.is_true(result)
    end)
end)
