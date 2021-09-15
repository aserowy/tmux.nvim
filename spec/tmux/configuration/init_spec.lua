describe("configuration", function()
    local config

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()
        require("spec.tmux.mocks.tmux_mock").setup("3.2a")

        _G.vim = {}
        _G.vim.tbl_deep_extend = function(_, _, _, t)
            return t
        end

        config = require("tmux.configuration")
    end)

    it("check default overwrites", function()
        config.setup({ copy_sync = { enable = true } })
        local result = require("tmux.configuration")
        assert.are.same(true, result.options.copy_sync.enable)

        config.setup({}, { file = "debug" })
        result = require("tmux.configuration")
        assert.are.same("debug", result.logging.file)
    end)

    it("check tmux not set will skip validation", function()
        require("tmux.wrapper.tmux").is_tmux = false

        local validated = false
        require("tmux.configuration.validate").options = function(_, _)
            validated = true
        end

        config.setup()

        assert.is_false(validated)
    end)
end)
