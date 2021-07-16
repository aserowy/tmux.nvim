describe("version comparing", function()
    local compare

    setup(function()
        compare = require("tmux.version.compare")
    end)

    local function generate(major, minor, patch)
        return {
            major = major,
            minor = minor,
            patch = patch,
        }
    end

    it("check invalid objects", function()
        local result = compare.with(generate(1), generate(1, 1, 1))
        assert.are.same({ error = "base: entry for minor is missing; entry for patch is missing; " }, result)

        result = compare.with(generate(1, 2, "test"), generate(1, 1, 1))
        assert.are.same({ error = "base: type for patch is not number; " }, result)

        result = compare.with(generate(1, 1, 1), generate(1))
        assert.are.same({ error = "relative: entry for minor is missing; entry for patch is missing; " }, result)

        result = compare.with(generate(1, 1, 1), generate(1, 2, "test"))
        assert.are.same({ error = "relative: type for patch is not number; " }, result)
    end)

    it("check equals", function()
        local result = compare.with(generate(1, 1, 1), generate(1, 1, 1))
        assert.are.same({ result = 0 }, result)
    end)

    it("check greater than", function()
        local result = compare.with(generate(1, 1, 1), generate(1, 1, 0))
        assert.are.same({ result = 1 }, result)

        result = compare.with(generate(1, 1, 1), generate(1, 0, 1))
        assert.are.same({ result = 1 }, result)

        result = compare.with(generate(1, 1, 1), generate(0, 1, 1))
        assert.are.same({ result = 1 }, result)
    end)

    it("check less than", function()
        local result = compare.with(generate(1, 1, 0), generate(1, 1, 1))
        assert.are.same({ result = -1 }, result)

        result = compare.with(generate(1, 0, 1), generate(1, 1, 1))
        assert.are.same({ result = -1 }, result)

        result = compare.with(generate(0, 1, 1), generate(1, 1, 1))
        assert.are.same({ result = -1 }, result)
    end)
end)
