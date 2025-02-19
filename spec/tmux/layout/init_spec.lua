---@diagnostic disable: duplicate-set-field
describe("check layout", function()
    local layout
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        layout = require("tmux.layout")
        tmux = require("tmux.wrapper.tmux")
    end)

    it("check invalid parsed layout", function()
        tmux.get_window_layout = function()
            return nil
        end
        tmux.get_current_pane_id = function()
            return 12
        end

        local result = layout.is_border("j")
        assert.are.same(nil, result)
    end)

    it("check invalid pane id", function()
        tmux.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        tmux.get_current_pane_id = function()
            return nil
        end
        local result = layout.is_border("j")
        assert.are.same(nil, result)

        tmux.get_current_pane_id = function()
            return "as"
        end
        result = layout.is_border("j")
        assert.are.same(nil, result)

        tmux.get_current_pane_id = function()
            return 12
        end
        result = layout.is_border("j")
        assert.are.same(nil, result)
    end)

    it("check invalid direction", function()
        tmux.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end
        tmux.get_current_pane_id = function()
            return 25
        end

        local result = layout.is_border("asdf")
        assert.are.same(nil, result)

        result = layout.is_border(nil)
        assert.are.same(nil, result)

        result = layout.is_border(345)
        assert.are.same(nil, result)
    end)

    it("check border left", function()
        tmux.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        tmux.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("h")
        assert.is_true(result)

        tmux.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("h")
        assert.is_false(result)

        tmux.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("h")
        assert.is_false(result)
    end)

    it("check border bottom", function()
        tmux.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        tmux.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("j")
        assert.is_true(result)

        tmux.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("j")
        assert.is_false(result)

        tmux.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("j")
        assert.is_true(result)
    end)

    it("check border top", function()
        tmux.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        tmux.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("k")
        assert.is_true(result)

        tmux.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("k")
        assert.is_true(result)

        tmux.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("k")
        assert.is_false(result)
    end)

    it("check border right", function()
        tmux.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        tmux.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("l")
        assert.is_false(result)

        tmux.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("l")
        assert.is_true(result)

        tmux.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("l")
        assert.is_true(result)
    end)
end)

describe("layout.has_tmux_target", function()
    local layout
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        layout = require("tmux.layout")
        tmux = require("tmux.wrapper.tmux")
    end)

    it("check is_tmux false", function()
        tmux.is_tmux = false

        local result = layout.has_tmux_target("h", false, true)
        assert.is_false(result)

        result = layout.has_tmux_target("j", false, true)
        assert.is_false(result)

        result = layout.has_tmux_target("k", false, true)
        assert.is_false(result)

        result = layout.has_tmux_target("l", false, true)
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

        local result = layout.has_tmux_target("h", true, true)
        assert.is_false(result)

        result = layout.has_tmux_target("j", true, true)
        assert.is_false(result)

        result = layout.has_tmux_target("k", true, true)
        assert.is_false(result)

        result = layout.has_tmux_target("l", true, true)
        assert.is_false(result)

        result = layout.has_tmux_target("h", false, true)
        assert.is_true(result)

        result = layout.has_tmux_target("j", false, true)
        assert.is_true(result)

        result = layout.has_tmux_target("k", false, true)
        assert.is_true(result)

        result = layout.has_tmux_target("l", false, true)
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

        local result = layout.has_tmux_target("h", false, true)
        assert.is_true(result)

        result = layout.has_tmux_target("j", false, true)
        assert.is_true(result)

        result = layout.has_tmux_target("k", false, true)
        assert.is_true(result)

        result = layout.has_tmux_target("l", false, true)
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

        local result = layout.has_tmux_target("h", false, false)
        assert.is_false(result)

        result = layout.has_tmux_target("j", false, false)
        assert.is_false(result)

        result = layout.has_tmux_target("k", false, false)
        assert.is_false(result)

        result = layout.has_tmux_target("l", false, false)
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

        local result = layout.has_tmux_target("h", false, false)
        assert.is_false(result)

        result = layout.has_tmux_target("h", false, true)
        assert.is_true(result)
    end)
end)
