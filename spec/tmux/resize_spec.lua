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
