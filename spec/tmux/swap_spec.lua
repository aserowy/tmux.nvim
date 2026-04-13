---@diagnostic disable: duplicate-set-field
describe("swap.to", function()
    local swap
    local layout
    local nvim
    local options
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        _G.vim = {
            v = { count = 1 },
            api = { nvim_set_keymap = function() end },
        }

        swap = require("tmux.swap")
        layout = require("tmux.layout")
        nvim = require("tmux.wrapper.nvim")
        options = require("tmux.configuration.options")
        tmux = require("tmux.wrapper.tmux")
    end)

    before_each(function()
        options.swap.cycle_navigation = false
        nvim.is_nvim_float = function()
            return false
        end
    end)

    it("invalid direction logs error and returns", function()
        nvim.is_nvim_border = function()
            return false
        end
        layout.has_tmux_target = function()
            return false
        end
        local swap_called = false
        tmux.swap = function()
            swap_called = true
        end
        swap.to("invalid")
        assert.is_false(swap_called)
    end)

    it("swaps via tmux when at nvim border with tmux target", function()
        nvim.is_nvim_border = function()
            return true
        end
        layout.has_tmux_target = function()
            return true
        end
        local called_dir = ""
        tmux.swap = function(dir)
            called_dir = dir
        end

        swap.to("left")
        assert.are.same("h", called_dir)

        swap.to("right")
        assert.are.same("l", called_dir)

        swap.to("top")
        assert.are.same("k", called_dir)

        swap.to("bottom")
        assert.are.same("j", called_dir)
    end)

    it("swaps via tmux when floating nvim window with tmux target", function()
        nvim.is_nvim_float = function()
            return true
        end
        nvim.is_nvim_border = function()
            return false
        end
        layout.has_tmux_target = function()
            return true
        end
        local called_dir = ""
        tmux.swap = function(dir)
            called_dir = dir
        end

        swap.to("left")
        assert.are.same("h", called_dir)
    end)

    it("cycles via nvim.swap when at border, no tmux target, cycle_navigation on", function()
        options.swap.cycle_navigation = true
        nvim.is_nvim_border = function()
            return true
        end
        layout.has_tmux_target = function()
            return false
        end
        local swap_dir = ""
        local swap_count = 0
        nvim.swap = function(dir, count)
            swap_dir = dir
            swap_count = count
        end

        swap.to("left") -- h → opposite = l
        assert.are.same("l", swap_dir)
        assert.are.same(999, swap_count)

        swap.to("right") -- l → opposite = h
        assert.are.same("h", swap_dir)
    end)

    it("swaps within nvim when not at border", function()
        nvim.is_nvim_border = function()
            return false
        end
        layout.has_tmux_target = function()
            return false
        end
        local swap_dir = ""
        nvim.swap = function(dir, _)
            swap_dir = dir
        end

        swap.to("left")
        assert.are.same("h", swap_dir)

        swap.to("bottom")
        assert.are.same("j", swap_dir)
    end)

    it("does nothing when at border, no tmux target, cycle_navigation off", function()
        options.swap.cycle_navigation = false
        nvim.is_nvim_border = function()
            return true
        end
        layout.has_tmux_target = function()
            return false
        end
        local nvim_swap_called = false
        local tmux_swap_called = false
        nvim.swap = function()
            nvim_swap_called = true
        end
        tmux.swap = function()
            tmux_swap_called = true
        end

        swap.to("left")
        assert.is_false(nvim_swap_called)
        assert.is_false(tmux_swap_called)
    end)
end)

describe("swap.to_left/bottom/top/right", function()
    local swap
    local nvim
    local layout

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        _G.vim = {
            v = { count = 1 },
            api = { nvim_set_keymap = function() end },
        }

        swap = require("tmux.swap")
        nvim = require("tmux.wrapper.nvim")
        layout = require("tmux.layout")
    end)

    before_each(function()
        -- simple path: not at border → nvim.swap
        nvim.is_nvim_float = function()
            return false
        end
        nvim.is_nvim_border = function()
            return false
        end
        layout.has_tmux_target = function()
            return false
        end
    end)

    it("to_left delegates to to('left')", function()
        local called_dir = ""
        nvim.swap = function(dir, _)
            called_dir = dir
        end
        swap.to_left()
        assert.are.same("h", called_dir)
    end)

    it("to_bottom delegates to to('bottom')", function()
        local called_dir = ""
        nvim.swap = function(dir, _)
            called_dir = dir
        end
        swap.to_bottom()
        assert.are.same("j", called_dir)
    end)

    it("to_top delegates to to('top')", function()
        local called_dir = ""
        nvim.swap = function(dir, _)
            called_dir = dir
        end
        swap.to_top()
        assert.are.same("k", called_dir)
    end)

    it("to_right delegates to to('right')", function()
        local called_dir = ""
        nvim.swap = function(dir, _)
            called_dir = dir
        end
        swap.to_right()
        assert.are.same("l", called_dir)
    end)
end)
