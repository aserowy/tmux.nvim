_G.vim = { o = { laststatus = 2 } }
---@diagnostic disable: duplicate-set-field
describe("tmux wrapper", function()
    local tmux

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        tmux = require("tmux.wrapper.tmux")
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

    describe("execute", function()
        before_each(function()
            tmux.execute = stub(tmux, "execute")
        end)

        it("select next window", function()
            tmux.select_window("n")
            assert.stub(tmux.execute).was.called_with("select-window -n")
        end)

        it("select previous window", function()
            tmux.select_window("p")
            assert.stub(tmux.execute).was.called_with("select-window -p")
        end)

        it("window_end_flag", function()
            tmux.window_end_flag()
            assert.stub(tmux.execute).was.called_with("display-message -p '#{window_end_flag}'")
        end)

        it("window_index", function()
            tmux.window_index()
            assert.stub(tmux.execute).was.called_with("display-message -p '#{window_index}'")
        end)

        it("base_index", function()
            tmux.base_index()
            assert.stub(tmux.execute).was.called_with("display-message -p '#{base-index}'")
        end)
    end)
end)
