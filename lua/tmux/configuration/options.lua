local M = {
	copy_sync = {
		-- enables copy sync and overwrites all register actions to
		-- sync registers *, +, unnamed, and 0 till 9 from tmux in advance
		enable = false,

		-- TMUX >= 3.2: yanks (and deletes) will get redirected to system
		-- clipboard by tmux
		redirect_to_clipboard = false,

		-- offset controls where register sync starts
		-- e.g. offset 2 lets registers 0 and 1 untouched
		register_offset = 0,

		-- syncs deletes with tmux clipboard as well, it is adviced to
		-- do so. Nvim does not allow syncing registers 0 and 1 without
		-- overwriting the unnamed register. Thus, ddp would not be possible.
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

function M.set(options)
	M.copy_sync = options.copy_sync
	M.navigation = options.navigation
	M.resize = options.resize
end

return M
