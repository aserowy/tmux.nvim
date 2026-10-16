describe("parse layout", function()
    local parser

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        parser = require("tmux.layout.parse")
    end)

    it("check invalid layouts", function()
        local layout = parser.parse(nil)
        assert.are.same(nil, layout)

        layout = parser.parse("")
        assert.are.same(nil, layout)

        local display = "623b,311x61,0,0{}"
        layout = parser.parse(display)
        assert.are.same(nil, layout)

        display = "623b,3,0,0{234x61,0,0,11}"
        layout = parser.parse(display)
        assert.are.same(nil, layout)
    end)

    it("check width and height", function()
        local display =
            -- luacheck: no max line length
            "932b,311x61,0,0{117x61,0,0[117x30,0,0,11,117x30,0,31{58x30,0,31,27,58x30,59,31,30}],116x61,118,0[116x30,118,0,26,116x15,118,31,28,116x14,118,47,29],76x61,235,0[76x30,235,0{38x30,235,0,20,37x30,274,0[37x15,274,0,22,37x14,274,16{18x14,274,16,23,18x14,293,16,24}]},76x15,235,31,21,76x14,235,47,25]}"

        local layout = parser.parse(display)

        assert.are.same(311, layout.width)
        assert.are.same(61, layout.height)
    end)

    it("check number of panes", function()
        local display =
            -- luacheck: no max line length
            "932b,311x61,0,0{117x61,0,0[117x30,0,0,11,117x30,0,31{58x30,0,31,27,58x30,59,31,30}],116x61,118,0[116x30,118,0,26,116x15,118,31,28,116x14,118,47,29],76x61,235,0[76x30,235,0{38x30,235,0,20,37x30,274,0[37x15,274,0,22,37x14,274,16{18x14,274,16,23,18x14,293,16,24}]},76x15,235,31,21,76x14,235,47,25]}"

        local layout = parser.parse(display)

        assert.are.same(12, #layout.panes)
    end)

    it("check pane mapping", function()
        local display =
            -- luacheck: no max line length
            "623b,311x61,0,0{234x61,0,0,11,76x61,235,0[76x49,235,0,20,76x11,235,50,25]}"

        local layout = parser.parse(display)

        assert.are.same(11, layout.panes[1].id)
        assert.are.same(0, layout.panes[1].x)
        assert.are.same(0, layout.panes[1].y)
        assert.are.same(234, layout.panes[1].width)
        assert.are.same(61, layout.panes[1].height)

        assert.are.same(20, layout.panes[2].id)
        assert.are.same(235, layout.panes[2].x)
        assert.are.same(0, layout.panes[2].y)
        assert.are.same(76, layout.panes[2].width)
        assert.are.same(49, layout.panes[2].height)

        assert.are.same(25, layout.panes[3].id)
        assert.are.same(235, layout.panes[3].x)
        assert.are.same(50, layout.panes[3].y)
        assert.are.same(76, layout.panes[3].width)
        assert.are.same(11, layout.panes[3].height)
    end)

    describe("json layout", function()
        local original_vim

        before_each(function()
            original_vim = _G.vim
        end)

        after_each(function()
            _G.vim = original_vim
        end)

        it("parses tmux 3.8 json layout", function()
            -- vim.json.decode is stubbed with the decoded form of the real tmux 3.8 output
            _G.vim = {
                json = {
                    decode = function()
                        return {
                            V = 2,
                            L = {
                                t = "v",
                                w = 150,
                                h = 73,
                                x = 0,
                                y = 0,
                                c = {
                                    { t = "p", w = 150, h = 36, x = 0, y = 0, a = true, i = 0, I = "%4" },
                                    {
                                        t = "h",
                                        w = 150,
                                        h = 36,
                                        x = 0,
                                        y = 37,
                                        c = {
                                            { t = "p", w = 75, h = 36, x = 0, y = 37, l = 0, i = 1, I = "%5" },
                                            { t = "p", w = 74, h = 36, x = 76, y = 37, l = 1, i = 2, I = "%16" },
                                        },
                                    },
                                },
                            },
                        }
                    end,
                },
            }

            local layout = parser.parse('{"V":2,"L":{}}')

            assert.are.same(150, layout.width)
            assert.are.same(73, layout.height)
            assert.are.same(3, #layout.panes)
            assert.are.same({ id = 5, x = 0, y = 37, width = 75, height = 36 }, layout.panes[2])
            assert.are.same(16, layout.panes[3].id)
        end)

        it("rejects json without a layout", function()
            _G.vim = {
                json = {
                    decode = function()
                        return { V = 2 }
                    end,
                },
            }
            assert.are.same(nil, parser.parse('{"V":2}'))
        end)
    end)
end)
