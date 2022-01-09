describe("version parsing", function()
    local parse

    setup(function()
        require("spec.tmux.mocks.log_mock").setup()

        parse = require("tmux.version.parse")
    end)

    it("check invalid version validation", function()
        local result = parse.from(nil)
        assert.are.same({}, result)

        result = parse.from("")
        assert.are.same({}, result)

        result = parse.from("a.0a")
        assert.are.same({}, result)

        result = parse.from("0.aa")
        assert.are.same({}, result)

        result = parse.from("0.9ab")
        assert.are.same({}, result)

        result = parse.from("0.9;")
        assert.are.same({}, result)

        result = parse.from("090")
        assert.are.same({}, result)

        result = parse.from("a3.0")
        assert.are.same({}, result)
    end)

    it("check parsing to semantic version (only numbers)", function()
        local result = parse.from("1.0")
        assert.are.same({ major = 1, minor = 0, patch = 0 }, result)

        result = parse.from("1.1")
        assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

        result = parse.from("01.01")
        assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

        result = parse.from("next1.1")
        assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

        result = parse.from("next-1.1")
        assert.are.same({ major = 1, minor = 1, patch = 0 }, result)

        result = parse.from("21.21")
        assert.are.same({ major = 21, minor = 21, patch = 0 }, result)

        result = parse.from("1.1a")
        assert.are.same({ major = 1, minor = 1, patch = 1 }, result)

        result = parse.from("1.1c")
        assert.are.same({ major = 1, minor = 1, patch = 3 }, result)

        result = parse.from("1.1z")
        assert.are.same({ major = 1, minor = 1, patch = 26 }, result)

        result = parse.from("next1.1a")
        assert.are.same({ major = 1, minor = 1, patch = 1 }, result)

        result = parse.from("next-1.1a")
        assert.are.same({ major = 1, minor = 1, patch = 1 }, result)
    end)
end)
