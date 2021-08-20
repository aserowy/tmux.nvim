---@diagnostic disable: duplicate-set-field
describe("check layout", function()
    local layout
    local wrapper

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        layout = require("tmux.layout")
        wrapper = require("tmux.wrapper")
    end)

    it("check invalid parsed layout", function()
        wrapper.get_window_layout = function()
            return nil
        end
        wrapper.get_current_pane_id = function()
            return 12
        end

        local result = layout.is_border("j")
        assert.are.same(nil, result)
    end)

    it("check invalid pane id", function()
        wrapper.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        wrapper.get_current_pane_id = function()
            return nil
        end
        local result = layout.is_border("j")
        assert.are.same(nil, result)

        wrapper.get_current_pane_id = function()
            return "as"
        end
        result = layout.is_border("j")
        assert.are.same(nil, result)

        wrapper.get_current_pane_id = function()
            return 12
        end
        result = layout.is_border("j")
        assert.are.same(nil, result)
    end)

    it("check invalid direction", function()
        wrapper.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end
        wrapper.get_current_pane_id = function()
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
        wrapper.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        wrapper.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("h")
        assert.is_true(result)

        wrapper.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("h")
        assert.is_false(result)

        wrapper.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("h")
        assert.is_false(result)
    end)

    it("check border bottom", function()
        wrapper.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        wrapper.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("j")
        assert.is_true(result)

        wrapper.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("j")
        assert.is_false(result)

        wrapper.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("j")
        assert.is_true(result)
    end)

    it("check border top", function()
        wrapper.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        wrapper.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("k")
        assert.is_true(result)

        wrapper.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("k")
        assert.is_true(result)

        wrapper.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("k")
        assert.is_false(result)
    end)

    it("check border right", function()
        wrapper.get_window_layout = function()
            return "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"
        end

        wrapper.get_current_pane_id = function()
            return 11
        end
        local result = layout.is_border("l")
        assert.is_false(result)

        wrapper.get_current_pane_id = function()
            return 20
        end
        result = layout.is_border("l")
        assert.is_true(result)

        wrapper.get_current_pane_id = function()
            return 25
        end
        result = layout.is_border("l")
        assert.is_true(result)
    end)
end)
