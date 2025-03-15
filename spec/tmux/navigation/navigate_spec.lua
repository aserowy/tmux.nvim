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
        _G.vim.fn = {
            getcmdwintype = function()
                return ""
            end,
        }
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

    it("check no navigation in command mode", function()
        _G.vim.fn = {
            getcmdwintype = function()
                return "="
            end,
        }
        options.navigation.cycle_navigation = false
        layout.has_tmux_target = function()
            return false
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
        assert.are.same("", last_called_direction)

        navigate.to("l")
        assert.are.same("", last_called_direction)
    end)
end)

describe("navigate.window", function()
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

        _G.vim = { v = { count = 1 } }
        _G.vim.fn = {
            getcmdwintype = function()
                return ""
            end,
        }
    end)

    it("next cycle", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        options.navigation.cycle_navigation = true
        assert.is_nil(navigate.window("n"))
        assert.equal("n", last_called_direction)
    end)

    it("previous cycle", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        options.navigation.cycle_navigation = true
        assert.is_nil(navigate.window("p"))
        assert.equal("p", last_called_direction)
    end)

    it("next completing", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        function nvim.is_completing()
            return true
        end
        assert.equal("<c-n>", navigate.window("n"))
        assert.is_nil(last_called_direction)
    end)

    it("previous completing", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        function nvim.is_completing()
            return true
        end
        assert.equal("<c-p>", navigate.window("p"))
        assert.is_nil(last_called_direction)
    end)

    it("next not cycle in center", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        function tmux.window_end_flag()
            return false
        end
        assert.is_nil(navigate.window("n"))
        assert.equal("n", last_called_direction)
    end)

    it("previous not cycle in center", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        function tmux.window_start_flag()
            return false
        end
        assert.is_nil(navigate.window("p"))
        assert.equal("p", last_called_direction)
    end)

    it("next not cycle on border", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        function tmux.window_end_flag()
            return true
        end
        assert.equal("<c-n>", navigate.window("n"))
        assert.is_nil(last_called_direction)
    end)

    it("previous not cycle on border", function()
        local last_called_direction
        function tmux.select_window(direction)
            last_called_direction = direction
        end
        function tmux.window_start_flag()
            return true
        end
        assert.equal("<c-p>", navigate.window("p"))
        assert.is_nil(last_called_direction)
    end)
end)
