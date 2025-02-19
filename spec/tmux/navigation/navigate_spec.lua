---@diagnostic disable: duplicate-set-field
describe("navigate.to", function()
    local navigate

    local layout
    local nvim
    local options
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        navigate = require("tmux.navigation.navigate")

        layout = require("tmux.layout")
        nvim = require("tmux.wrapper.nvim")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")

        _G.vim = { v = { count = 1 } }
    end)

    it("check with no nvim borders", function()
        options.navigation.cycle_navigation = false
        layout.has_tmux_target = function()
            return true
        end
        nvim.is_nvim_border = function()
            return false
        end
        nvim.is_nvim_float = function()
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
        layout.has_tmux_target = function()
            return false
        end
        nvim.is_nvim_border = function()
            return true
        end
        nvim.is_nvim_float = function()
            return false
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
        layout.has_tmux_target = function()
            return false
        end
        nvim.is_nvim_border = function()
            return true
        end
        nvim.is_nvim_float = function()
            return false
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
        layout.has_tmux_target = function()
            return true
        end
        nvim.is_nvim_border = function()
            return true
        end
        nvim.is_nvim_float = function()
            return false
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

    it("check with nvim float win", function()
        options.navigation.cycle_navigation = true
        layout.has_tmux_target = function()
            return true
        end
        nvim.is_nvim_border = function()
            return false
        end
        nvim.is_nvim_float = function()
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
