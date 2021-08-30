---@diagnostic disable: duplicate-set-field
describe("navigate.has_tmux_target", function()
    local navigate

    local layout
    local options
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        navigate = require("tmux.navigation.navigate")

        layout = require("tmux.layout")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    it("check is_tmux false", function()
        tmux.is_tmux = false

        local result = navigate.has_tmux_target("h")
        assert.is_false(result)

        result = navigate.has_tmux_target("j")
        assert.is_false(result)

        result = navigate.has_tmux_target("k")
        assert.is_false(result)

        result = navigate.has_tmux_target("l")
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

        options.navigation.persist_zoom = true

        local result = navigate.has_tmux_target("h")
        assert.is_false(result)

        result = navigate.has_tmux_target("j")
        assert.is_false(result)

        result = navigate.has_tmux_target("k")
        assert.is_false(result)

        result = navigate.has_tmux_target("l")
        assert.is_false(result)

        options.navigation.persist_zoom = false

        result = navigate.has_tmux_target("h")
        assert.is_true(result)

        result = navigate.has_tmux_target("j")
        assert.is_true(result)

        result = navigate.has_tmux_target("k")
        assert.is_true(result)

        result = navigate.has_tmux_target("l")
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

        local result = navigate.has_tmux_target("h")
        assert.is_true(result)

        result = navigate.has_tmux_target("j")
        assert.is_true(result)

        result = navigate.has_tmux_target("k")
        assert.is_true(result)

        result = navigate.has_tmux_target("l")
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

        options.navigation.cycle_navigation = false

        local result = navigate.has_tmux_target("h")
        assert.is_false(result)

        result = navigate.has_tmux_target("j")
        assert.is_false(result)

        result = navigate.has_tmux_target("k")
        assert.is_false(result)

        result = navigate.has_tmux_target("l")
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

        options.navigation.cycle_navigation = false
        local result = navigate.has_tmux_target("h")
        assert.is_false(result)

        options.navigation.cycle_navigation = true
        result = navigate.has_tmux_target("h")
        assert.is_true(result)
    end)
end)

describe("navigate.to", function()
    local navigate

    local nvim
    local options
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        navigate = require("tmux.navigation.navigate")

        nvim = require("tmux.wrapper.nvim")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    it("check with no nvim borders", function()
        options.navigation.cycle_navigation = false
        navigate.has_tmux_target = function()
            return true
        end
        nvim.is_nvim_border = function()
            return false
        end

        local last_called_direction = ""
        nvim.wincmd = function(direction)
            last_called_direction = direction
        end

        navigate.to("h")
        assert.are.same("h", last_called_direction)

        navigate.to("j")
        assert.are.same("j", last_called_direction)

        navigate.to("k")
        assert.are.same("k", last_called_direction)

        navigate.to("l")
        assert.are.same("l", last_called_direction)
    end)

    it("check with nvim border and tmux border", function()
        options.navigation.cycle_navigation = false
        navigate.has_tmux_target = function()
            return false
        end
        nvim.is_nvim_border = function()
            return true
        end

        local last_called_direction = ""
        nvim.wincmd = function(direction)
            last_called_direction = direction
        end

        navigate.to("h")
        assert.are.same("", last_called_direction)

        navigate.to("j")
        assert.are.same("", last_called_direction)

        navigate.to("k")
        assert.are.same("", last_called_direction)

        navigate.to("l")
        assert.are.same("", last_called_direction)
    end)

    it("check cycle_navigation on only nvim pane", function()
        options.navigation.cycle_navigation = true
        navigate.has_tmux_target = function()
            return false
        end
        nvim.is_nvim_border = function()
            return true
        end

        local last_called_direction = ""
        nvim.wincmd = function(direction, count)
            assert.is_true(count > 500)
            last_called_direction = direction
        end

        navigate.to("h")
        assert.are.same("l", last_called_direction)

        navigate.to("j")
        assert.are.same("k", last_called_direction)

        navigate.to("k")
        assert.are.same("j", last_called_direction)

        navigate.to("l")
        assert.are.same("h", last_called_direction)
    end)

    it("check change tmux pane on nvim border", function()
        options.navigation.cycle_navigation = true
        navigate.has_tmux_target = function()
            return true
        end
        nvim.is_nvim_border = function()
            return true
        end

        local last_called_direction = ""
        tmux.change_pane = function(direction)
            last_called_direction = direction
        end

        navigate.to("h")
        assert.are.same("h", last_called_direction)

        navigate.to("j")
        assert.are.same("j", last_called_direction)

        navigate.to("k")
        assert.are.same("k", last_called_direction)

        navigate.to("l")
        assert.are.same("l", last_called_direction)
    end)
end)
