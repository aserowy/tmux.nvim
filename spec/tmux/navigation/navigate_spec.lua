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

-- ---------------------------------------------------------------------------
-- Integration tests: snacks picker active → navigate.to() exercises the real
-- nvim.is_nvim_border / nvim.is_nvim_float code paths through the snacks module.
-- ---------------------------------------------------------------------------
describe("navigate.to with snacks picker", function()
    local navigate
    local layout
    local nvim
    local options
    local tmux
    local snacks_mock

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")
        snacks_mock = require("spec.tmux.mocks.snacks_mock")

        navigate = require("tmux.navigation.navigate")
        layout = require("tmux.layout")
        nvim = require("tmux.wrapper.nvim")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    before_each(function()
        _G.Snacks = nil
        -- Restore the real implementations each time; earlier describe blocks
        -- replace these functions with stubs and never restore them.
        -- Re-load from scratch to get original implementations.
        package.loaded["tmux.wrapper.snacks"] = nil
        package.loaded["tmux.wrapper.nvim"] = nil
        package.loaded["tmux.navigation.navigate"] = nil
        nvim = require("tmux.wrapper.nvim")
        navigate = require("tmux.navigation.navigate")
        -- Full vim stub needed by nvim.lua and snacks.lua
        _G.vim = {
            v = { count = 1 },
            api = {
                nvim_win_get_config = function(_)
                    return { relative = "" }
                end,
                nvim_command = function(_) end,
                nvim_call_function = function(_, _)
                    return 1
                end,
            },
            fn = {
                getcmdwintype = function()
                    return ""
                end,
            },
        }
        snacks_mock.setup()

        options.navigation.cycle_navigation = false
        options.navigation.persist_zoom = false
    end)

    after_each(function()
        _G.Snacks = nil
    end)

    it("tiled picker at left border: navigates to tmux pane", function()
        snacks_mock.set_focused_picker(snacks_mock.make_picker("left", "left"))
        layout.has_tmux_target = function()
            return true
        end

        local called_direction = ""
        tmux.change_pane = function(dir)
            called_direction = dir
        end
        local wincmd_called = false
        nvim.wincmd = function(_)
            wincmd_called = true
        end

        navigate.to("h")

        assert.are.same("h", called_direction)
        assert.is_false(wincmd_called)
    end)

    it("tiled picker at left border: moves inside nvim when direction is away from border", function()
        snacks_mock.set_focused_picker(snacks_mock.make_picker("left", "left"))
        layout.has_tmux_target = function()
            return false
        end

        local wincmd_direction = ""
        nvim.wincmd = function(dir)
            wincmd_direction = dir
        end

        navigate.to("l")

        assert.are.same("l", wincmd_direction)
    end)

    it("floating picker: navigates to tmux pane regardless of border", function()
        snacks_mock.set_focused_picker(snacks_mock.make_picker(nil, nil))
        layout.has_tmux_target = function()
            return true
        end

        local called_direction = ""
        tmux.change_pane = function(dir)
            called_direction = dir
        end

        navigate.to("h")

        assert.are.same("h", called_direction)
    end)

    it("floating picker with no tmux target: moves inside nvim", function()
        snacks_mock.set_focused_picker(snacks_mock.make_picker(nil, nil))
        layout.has_tmux_target = function()
            return false
        end

        local wincmd_direction = ""
        nvim.wincmd = function(dir)
            wincmd_direction = dir
        end

        navigate.to("l")

        assert.are.same("l", wincmd_direction)
    end)
end)

describe("navigate.window", function()
    local navigate
    local options
    local tmux
    local flag_value = true

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")
        navigate = require("tmux.navigation.navigate")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    before_each(function()
        tmux = mock(tmux, true, function()
            return flag_value
        end)
    end)

    after_each(function()
        mock.revert(tmux)
    end)

    describe("cycle", function()
        before_each(function()
            options.navigation.cycle_navigation = true
        end)

        it("next", function()
            navigate.window("n")
            assert.stub(tmux.window_start_flag).was_not.called()
            assert.stub(tmux.window_end_flag).was_not.called()
            assert.stub(tmux.select_window).was_not.called_with("p")
            assert.stub(tmux.select_window).was.called_with("n")
        end)

        it("previous", function()
            navigate.window("p")
            assert.stub(tmux.window_start_flag).was_not.called()
            assert.stub(tmux.window_end_flag).was_not.called()
            assert.stub(tmux.select_window).was_not.called_with("n")
            assert.stub(tmux.select_window).was.called_with("p")
        end)
    end)

    describe("no cycle", function()
        before_each(function()
            options.navigation.cycle_navigation = false
            tmux.is_tmux = true
        end)

        describe("center", function()
            before_each(function()
                flag_value = false
            end)

            it("next", function()
                navigate.window("n")
                assert.stub(tmux.window_end_flag).was.called()
                assert.stub(tmux.window_start_flag).was_not.called()
                assert.stub(tmux.select_window).was_not.called_with("p")
                assert.stub(tmux.select_window).was.called_with("n")
            end)

            it("previous", function()
                navigate.window("p")
                assert.stub(tmux.window_end_flag).was_not.called()
                assert.stub(tmux.window_start_flag).was.called()
                assert.stub(tmux.select_window).was_not.called_with("n")
                assert.stub(tmux.select_window).was.called_with("p")
            end)
        end)

        describe("border", function()
            before_each(function()
                flag_value = true
            end)

            it("next", function()
                navigate.window("n")
                assert.stub(tmux.window_end_flag).was.called()
                assert.stub(tmux.window_start_flag).was_not.called()
                assert.stub(tmux.select_window).was_not.called_with("n")
                assert.stub(tmux.select_window).was_not.called_with("p")
            end)

            it("previous", function()
                navigate.window("p")
                assert.stub(tmux.window_end_flag).was_not.called()
                assert.stub(tmux.window_start_flag).was.called()
                assert.stub(tmux.select_window).was_not.called_with("n")
                assert.stub(tmux.select_window).was_not.called_with("p")
            end)
        end)
    end)
end)

describe("navigation.to", function()
    local navigation
    local navigate

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        navigation = require("tmux.navigation")
        navigate = require("tmux.navigation.navigate")
    end)

    before_each(function()
        navigate.to = stub(navigate, "to")
    end)

    it("left maps to h", function()
        navigation.to("left")
        assert.stub(navigate.to).was.called_with("h")
    end)

    it("right maps to l", function()
        navigation.to("right")
        assert.stub(navigate.to).was.called_with("l")
    end)

    it("top maps to k", function()
        navigation.to("top")
        assert.stub(navigate.to).was.called_with("k")
    end)

    it("bottom maps to j", function()
        navigation.to("bottom")
        assert.stub(navigate.to).was.called_with("j")
    end)

    it("invalid direction does not call navigate.to", function()
        navigation.to("invalid")
        assert.stub(navigate.to).was_not.called()
    end)
end)

describe("navigation.to_left/bottom/top/right", function()
    local navigation
    local navigate

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        navigation = require("tmux.navigation")
        navigate = require("tmux.navigation.navigate")
    end)

    before_each(function()
        navigate.to = stub(navigate, "to")
    end)

    it("to_left calls navigate.to with h", function()
        navigation.to_left()
        assert.stub(navigate.to).was.called_with("h")
    end)

    it("to_bottom calls navigate.to with j", function()
        navigation.to_bottom()
        assert.stub(navigate.to).was.called_with("j")
    end)

    it("to_top calls navigate.to with k", function()
        navigation.to_top()
        assert.stub(navigate.to).was.called_with("k")
    end)

    it("to_right calls navigate.to with l", function()
        navigation.to_right()
        assert.stub(navigate.to).was.called_with("l")
    end)
end)
