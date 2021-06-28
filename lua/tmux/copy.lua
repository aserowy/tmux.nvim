-- aucmd TextYankPost check if 0 then set-buffer
local keymaps = require("tmux.keymaps")
local wrapper = require("tmux.wrapper")

local function rtc(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function sync_register(index, buffer_name)
	local content = wrapper.get_buffer(buffer_name)
	vim.fn.setreg(tostring(index), content)
end

local function sync_registers(passed_key)
	for k, v in ipairs(wrapper.get_buffer_names()) do
		if k == 11 then
			return rtc(passed_key)
		end
		sync_register(k - 1, v)
	end
	return rtc(passed_key)
end

local M = {}
function M.setup()
	if not wrapper.is_tmux then
		return
	end

	keymaps.register("n", {
		['"'] = [[v:lua.tmux.yank('"')]],
	}, { expr = true, noremap = true })

	keymaps.register("i", {
		["C-r"] = [[v:lua.tmux.yank("C-r")]],
	}, { expr = true, noremap = true })

	_G.tmux = {
		yank = sync_registers,
	}

	vim.g.clipboard = {
		name = "myClipboard",
		copy = {
			["+"] = "tmux load-buffer -",
			["*"] = "tmux load-buffer -",
		},
		paste = {
			["+"] = "tmux save-buffer -",
			["*"] = "tmux save-buffer -",
		},
	}
	-- \   'cache_enabled': 1,
end

return M
