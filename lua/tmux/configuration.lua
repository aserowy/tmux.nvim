local vim = vim

local defaults = {
	navigation = {
		-- cycles to opposite pane while navigating into the border
		cycle_navigation = true,

		-- enables default keybindings (C-hjkl) for normal mode
		enable_default_keybindings = false,

		-- prevents unzoom tmux when navigating beyond vim border
		persist_zoom = false,
	},
	resize = {
		-- enables default keybindings (A-hjkl) for normal mode
		enable_default_keybindings = false,
	},
}

local M = {
	options = {},
}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

M.setup()

return M
