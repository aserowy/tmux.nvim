local vim = vim

local defaults = {
	copy_sync = {
		enable = false,
		redirect_to_clipboard = false,
		register_offset = 0,
		sync_deletes = false,
	},
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

		-- sets resize steps for x axis
		resize_step_x = 1,

		-- sets resize steps for y axis
		resize_step_y = 1,
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
