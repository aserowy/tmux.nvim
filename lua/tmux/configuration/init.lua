local options = require("tmux.configuration.options")
local validate = require("tmux.configuration.validate")
local wrapper = require("tmux.wrapper")

local M = {
	options = options,
}

function M.setup(custom)
	M.options.set(vim.tbl_deep_extend("force", {}, M.options, custom or {}))

	validate.options(wrapper.version, M.options)
end

return M
