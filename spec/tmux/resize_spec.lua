---@diagnostic disable: duplicate-set-field
describe("resize", function()
    -- local resize

    local layout
    local options
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        -- resize = require("tmux.resize")

        layout = require("tmux.layout")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    it("check is_tmux false", function()
        tmux.is_tmux = false
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
    end)

    it("check is_border false", function()
        tmux.is_tmux = true
        tmux.is_zoomed = function()
            return false
        end
        layout.is_border = function(_)
            return false
        end
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
    end)
end)

describe("resize.to", function()
    local resize

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        _G.vim = { api = { nvim_set_keymap = function() end } }

        resize = require("tmux.resize")
    end)

    before_each(function()
        resize.to_left = stub(resize, "to_left")
        resize.to_right = stub(resize, "to_right")
        resize.to_top = stub(resize, "to_top")
        resize.to_bottom = stub(resize, "to_bottom")
    end)

    it("left calls to_left", function()
        resize.to("left")
        assert.stub(resize.to_left).was.called_with(nil)
        assert.stub(resize.to_right).was_not.called()
        assert.stub(resize.to_top).was_not.called()
        assert.stub(resize.to_bottom).was_not.called()
    end)

    it("right calls to_right", function()
        resize.to("right")
        assert.stub(resize.to_right).was.called_with(nil)
        assert.stub(resize.to_left).was_not.called()
        assert.stub(resize.to_top).was_not.called()
        assert.stub(resize.to_bottom).was_not.called()
    end)

    it("top calls to_top", function()
        resize.to("top")
        assert.stub(resize.to_top).was.called_with(nil)
        assert.stub(resize.to_left).was_not.called()
        assert.stub(resize.to_right).was_not.called()
        assert.stub(resize.to_bottom).was_not.called()
    end)

    it("bottom calls to_bottom", function()
        resize.to("bottom")
        assert.stub(resize.to_bottom).was.called_with(nil)
        assert.stub(resize.to_left).was_not.called()
        assert.stub(resize.to_right).was_not.called()
        assert.stub(resize.to_top).was_not.called()
    end)

    it("forwards step argument", function()
        resize.to("left", 5)
        assert.stub(resize.to_left).was.called_with(5)
    end)

    it("invalid direction does not call any to_* function", function()
        resize.to("invalid")
        assert.stub(resize.to_left).was_not.called()
        assert.stub(resize.to_right).was_not.called()
        assert.stub(resize.to_top).was_not.called()
        assert.stub(resize.to_bottom).was_not.called()
    end)
end)

describe("resize.to_left/bottom/top/right integration", function()
    local resize
    local layout
    local nvim
    local options
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        _G.vim = {
            api = { nvim_set_keymap = function() end },
            fn = {
                win_move_separator = function() end,
                win_move_statusline = function() end,
            },
        }

        -- reload resize so it picks up fresh module state
        package.loaded["tmux.resize"] = nil
        resize = require("tmux.resize")
        layout = require("tmux.layout")
        nvim = require("tmux.wrapper.nvim")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    before_each(function()
        options.resize.resize_step_x = 2
        options.resize.resize_step_y = 3
        nvim.is_nvim_float = function()
            return false
        end
    end)

    it("to_left: tmux path when at right border with tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "l"
        end
        layout.is_tmux_target = function()
            return true
        end
        local called_dir, called_step
        tmux.resize = function(dir, step)
            called_dir = dir
            called_step = step
        end
        resize.to_left()
        assert.are.same("h", called_dir)
        assert.are.same(2, called_step)
    end)

    it("to_left: nvim resize when at right border, no tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "l"
        end
        layout.is_tmux_target = function()
            return false
        end
        local called_axis, called_sign
        nvim.resize = function(axis, sign, _)
            called_axis = axis
            called_sign = sign
        end
        resize.to_left()
        assert.are.same("x", called_axis)
        assert.are.same("+", called_sign)
    end)

    it("to_left: win_move_separator when not at border", function()
        nvim.is_nvim_border = function()
            return false
        end
        layout.is_tmux_target = function()
            return false
        end
        local sep_delta
        _G.vim.fn.win_move_separator = function(_, delta)
            sep_delta = delta
        end
        resize.to_left()
        assert.are.same(-2, sep_delta)
    end)

    it("to_right: tmux path when at right border with tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "l"
        end
        layout.is_tmux_target = function()
            return true
        end
        local called_dir
        tmux.resize = function(dir, _)
            called_dir = dir
        end
        resize.to_right()
        assert.are.same("l", called_dir)
    end)

    it("to_right: nvim resize when at right border, no tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "l"
        end
        layout.is_tmux_target = function()
            return false
        end
        local called_sign
        nvim.resize = function(_, sign, _)
            called_sign = sign
        end
        resize.to_right()
        assert.are.same("-", called_sign)
    end)

    it("to_right: win_move_separator when not at border", function()
        nvim.is_nvim_border = function()
            return false
        end
        layout.is_tmux_target = function()
            return false
        end
        local sep_delta
        _G.vim.fn.win_move_separator = function(_, delta)
            sep_delta = delta
        end
        resize.to_right()
        assert.are.same(2, sep_delta)
    end)

    it("to_bottom: tmux path when at bottom border with tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "j"
        end
        layout.is_tmux_target = function()
            return true
        end
        local called_dir
        tmux.resize = function(dir, _)
            called_dir = dir
        end
        resize.to_bottom()
        assert.are.same("j", called_dir)
    end)

    it("to_bottom: nvim resize when at bottom border, no tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "j"
        end
        layout.is_tmux_target = function()
            return false
        end
        local called_axis, called_sign
        nvim.resize = function(axis, sign, _)
            called_axis = axis
            called_sign = sign
        end
        resize.to_bottom()
        assert.are.same("y", called_axis)
        assert.are.same("-", called_sign)
    end)

    it("to_bottom: win_move_statusline when not at border", function()
        nvim.is_nvim_border = function()
            return false
        end
        layout.is_tmux_target = function()
            return false
        end
        local sl_delta
        _G.vim.fn.win_move_statusline = function(_, delta)
            sl_delta = delta
        end
        resize.to_bottom()
        assert.are.same(3, sl_delta)
    end)

    it("to_top: tmux path when at bottom border with tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "j"
        end
        layout.is_tmux_target = function()
            return true
        end
        local called_dir
        tmux.resize = function(dir, _)
            called_dir = dir
        end
        resize.to_top()
        assert.are.same("k", called_dir)
    end)

    it("to_top: nvim resize when at bottom border, no tmux target", function()
        nvim.is_nvim_border = function(dir)
            return dir == "j"
        end
        layout.is_tmux_target = function()
            return false
        end
        local called_sign
        nvim.resize = function(_, sign, _)
            called_sign = sign
        end
        resize.to_top()
        assert.are.same("+", called_sign)
    end)

    it("to_top: win_move_statusline when not at border", function()
        nvim.is_nvim_border = function()
            return false
        end
        layout.is_tmux_target = function()
            return false
        end
        local sl_delta
        _G.vim.fn.win_move_statusline = function(_, delta)
            sl_delta = delta
        end
        resize.to_top()
        assert.are.same(-3, sl_delta)
    end)

    it("to_left forwards explicit step, overriding default", function()
        nvim.is_nvim_border = function()
            return false
        end
        layout.is_tmux_target = function()
            return false
        end
        local sep_delta
        _G.vim.fn.win_move_separator = function(_, delta)
            sep_delta = delta
        end
        resize.to_left(10)
        assert.are.same(-10, sep_delta)
    end)

    it("to_left: tmux path when floating nvim window with tmux target", function()
        nvim.is_nvim_float = function()
            return true
        end
        nvim.is_nvim_border = function()
            return false
        end
        layout.is_tmux_target = function()
            return true
        end
        local called_dir
        tmux.resize = function(dir, _)
            called_dir = dir
        end
        resize.to_left()
        assert.are.same("h", called_dir)
    end)
end)
