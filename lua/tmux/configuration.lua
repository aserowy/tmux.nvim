local vim = vim

local defaults = {
	-- TODO: change to log with severity
	debug = false,
	copy_sync = {
		-- enables copy sync and overwrites all register actions to
		-- sync registers *, +, and 0 till 9 from tmux in advance
		enable = false,

		-- yanks (and deletes) will get redirected to system clipboard
		-- by tmux
		redirect_to_clipboard = false,

		-- offset controls where register sync starts
		-- e.g. offset 2 lets registers 0 and 1 untouched
		register_offset = 0,

		-- syncs deletes with tmux clipboard as well
		sync_deletes = true,
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
