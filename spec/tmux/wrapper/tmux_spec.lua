---@diagnostic disable: duplicate-set-field
describe("tmux wrapper", function()
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()

        tmux = require("tmux.wrapper.tmux")
        _G.vim = { o = { laststatus = 2 } }
    end)

    it("check get_tmux_pane with nil env", function()
        local orig_getenv = os.getenv
        os.getenv = function(var)
            if var == "TMUX_PANE" then
                return nil
            end
            return orig_getenv(var)
        end

        local result = tmux.get_current_pane_id()
        assert.are.same(nil, result)

        os.getenv = orig_getenv
    end)

    it("check get_tmux_pane with valid env", function()
        local orig_getenv = os.getenv
        os.getenv = function(var)
            if var == "TMUX_PANE" then
                return "%12"
            end
            return orig_getenv(var)
        end

        local result = tmux.get_current_pane_id()
        assert.are.same(12, result)

        os.getenv = orig_getenv
    end)
end)
