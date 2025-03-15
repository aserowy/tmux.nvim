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
    local options
    local tmux
    local select_window
    local window_end_flag
    local window_index
    local base_index
    local window_index_value = 1
    local base_index_value = 0
    local window_end_flag_value = false

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")
        navigate = require("tmux.navigation.navigate")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    before_each(function()
        select_window = mock(tmux.select_window)
        window_end_flag = mock(tmux.window_end_flag, false, function()
            return window_end_flag_value
        end)
        window_index = mock(tmux.window_index, false, function()
            return window_index_value
        end)
        base_index = mock(tmux.base_index, false, function()
            return base_index_value
        end)
    end)

    after_each(function()
        mock.revert(select_window)
        mock.revert(window_end_flag)
        mock.revert(window_index)
        mock.revert(base_index)
    end)

    describe("cycle", function()
        before_each(function()
            options.navigation.cycle_navigation = true
        end)

        it("next", function()
            navigate.window("n")
            assert.stub(select_window).was_not.called_with("p")
            assert.stub(select_window).was.called_with("n")
        end)

        it("previous", function()
            navigate.window("p")
            assert.stub(select_window).was_not.called_with("n")
            assert.stub(select_window).was.called_with("p")
        end)
    end)

    describe("no cycle", function()
        before_each(function()
            options.navigation.cycle_navigation = false
        end)

        describe("center", function()
            it("next", function()
                navigate.window("n")
                assert.stub(select_window).was_not.called_with("p")
                assert.stub(select_window).was.called_with("n")
            end)

            it("previous", function()
                navigate.window("p")
                assert.stub(select_window).was_not.called_with("n")
                assert.stub(select_window).was.called_with("p")
            end)
        end)

        it("next not cycle on border", function()
            window_end_flag_value = true
            navigate.window("n")
            window_end_flag_value = false
            assert.stub(select_window).was_not.called_with("n")
            assert.stub(select_window).was_not.called_with("p")
        end)

        it("previous not cycle on border", function()
            window_index_value = 0
            navigate.window("p")
            window_index_value = 1
            assert.stub(select_window).was_not.called_with("n")
            assert.stub(select_window).was_not.called_with("p")
        end)
    end)
end)
