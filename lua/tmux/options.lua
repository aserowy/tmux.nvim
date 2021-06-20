local vim = vim

local defaults = {
	navigation = {
		cycle_navigation = true,
		persistend_zoom = false,
	},
}

local M = {
	options = {},
}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
