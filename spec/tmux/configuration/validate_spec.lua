describe("configuration validation", function()
    local options
    local validate

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()

        options = require("tmux.configuration.options")
        validate = require("tmux.configuration.validate")
    end)

    it("check invalid version", function()
        options.copy_sync.enable = true

        options.copy_sync.redirect_to_clipboard = true
        validate.options("3.", options)
        assert.are.same(true, options.copy_sync.redirect_to_clipboard)
    end)

    it("check ignore redirect_to_clipboard while sync is disabled", function()
        options.copy_sync.enable = false

        options.copy_sync.redirect_to_clipboard = true
        validate.options("3.0", options)
        assert.are.same(true, options.copy_sync.redirect_to_clipboard)
    end)

    it("check redirect_to_clipboard", function()
        options.copy_sync.enable = true

        options.copy_sync.redirect_to_clipboard = true
        validate.options("3.0", options)
        assert.are.same(false, options.copy_sync.redirect_to_clipboard)

        options.copy_sync.redirect_to_clipboard = true
        validate.options("3.2", options)
        assert.are.same(true, options.copy_sync.redirect_to_clipboard)

        options.copy_sync.redirect_to_clipboard = true
        validate.options("3.3", options)
        assert.are.same(true, options.copy_sync.redirect_to_clipboard)
    end)
end)
