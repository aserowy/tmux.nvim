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
            assert.stub(tmux.execute).was.called_with({ "select-window", "-n" })
        end)

        it("select previous window", function()
            tmux.select_window("p")
            assert.stub(tmux.execute).was.called_with({ "select-window", "-p" })
        end)

        it("window_end_flag", function()
            tmux.window_end_flag()
            assert.stub(tmux.execute).was.called_with({ "display-message", "-p", "#{window_end_flag}" })
        end)

        it("window_index", function()
            tmux.window_index()
            assert.stub(tmux.execute).was.called_with({ "display-message", "-p", "#{window_index}" })
        end)

        it("base_index", function()
            tmux.base_index()
            assert.stub(tmux.execute).was.called_with({ "display-message", "-p", "#{base-index}" })
        end)

        it("set_buffer passes content on stdin", function()
            tmux.set_buffer([["quoted" $var `cmd` \]], false)
            assert.stub(tmux.execute).was.called_with({ "load-buffer", "-" }, [["quoted" $var `cmd` \]])
        end)

        it("set_buffer with clipboard sync", function()
            tmux.set_buffer("content", true)
            assert.stub(tmux.execute).was.called_with({ "load-buffer", "-w", "-" }, "content")
        end)
    end)
end)

describe("tmux wrapper execute", function()
    local tmux
    local orig_vim
    local orig_getenv
    local calls

    before_each(function()
        orig_vim = _G.vim
        orig_getenv = os.getenv
        calls = {}

        os.getenv = function(var)
            if var == "TMUX" then
                return "/tmp/tmux-1/default,123,0"
            end
            return orig_getenv(var)
        end
        _G.vim = {
            split = function(str, sep)
                return { str:match("^(.-)" .. sep) }
            end,
            list_extend = function(dst, src)
                for _, v in ipairs(src) do
                    table.insert(dst, v)
                end
                return dst
            end,
            system = function(command, opts)
                table.insert(calls, { command = command, opts = opts })
                return {
                    wait = function()
                        return { code = 0, stdout = "out" }
                    end,
                }
            end,
        }

        -- the module captures `vim` when loaded, so load a fresh copy
        package.loaded["tmux.wrapper.tmux"] = nil
        tmux = require("tmux.wrapper.tmux")
    end)

    after_each(function()
        _G.vim = orig_vim
        os.getenv = orig_getenv
        package.loaded["tmux.wrapper.tmux"] = nil
    end)

    it("reads zoom and layout from one call", function()
        _G.vim.system = function()
            return {
                wait = function()
                    return { stdout = "1 abc,1x1,0,0,0\n" }
                end,
            }
        end

        local is_zoomed, layout = tmux.get_window_zoom_and_layout()
        assert.is_true(is_zoomed)
        assert.are.same("abc,1x1,0,0,0\n", layout)
    end)

    it("runs tmux on the current socket without a shell", function()
        local result = tmux.execute({ "load-buffer", "-" }, "content")

        assert.are.same("out", result)
        assert.are.same({ "tmux", "-S", "/tmp/tmux-1/default", "load-buffer", "-" }, calls[1].command)
        assert.are.same("content", calls[1].opts.stdin)
    end)
end)
