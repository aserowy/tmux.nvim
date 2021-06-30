local cfg = require("tmux.configuration")
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
    local offset = cfg.options.copy_sync.register_offset
	for k, v in ipairs(wrapper.get_buffer_names()) do
		if k >= 11 - offset then
			return rtc(passed_key)
		end
		sync_register(k - 1 + offset, v)
	end
	return rtc(passed_key)
end

local M = {}
function M.setup()
	if not wrapper.is_tmux or not cfg.options.copy_sync.enable then
		return
	end

	vim.cmd([[
        if !exists("tmux_autocommands_loaded")
            let tmux_autocommands_loaded = 1
            let PostYank = luaeval('require("tmux").post_yank')
            autocmd TextYankPost * call PostYank(v:event)
        endif
    ]])

	_G.tmux = {
		sync_registers = sync_registers,
	}

	keymaps.register("n", {
		['"'] = [[v:lua.tmux.sync_registers('"')]],
		["p"] = [[v:lua.tmux.sync_registers('p')]],
		["P"] = [[v:lua.tmux.sync_registers('P')]],
	}, {
		expr = true,
		noremap = true,
	})

	-- double C-r to prevent injection: https://vim.fandom.com/wiki/Pasting_registers#In_insert_and_command-line_modes
	keymaps.register("i", {
		["<C-r>"] = [[v:lua.tmux.sync_registers("<C-r><C-r>")]],
	}, {
		expr = true,
		noremap = true,
	})

	keymaps.register("c", {
		["<C-r>"] = [[v:lua.tmux.sync_registers("<C-r><C-r>")]],
	}, {
		expr = true,
		noremap = true,
	})

	vim.g.clipboard = {
		name = "tmuxclipboard",
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

function M.post_yank(content)
	if content.operator ~= "y" and not cfg.options.copy_sync.sync_deletes then
		return
	end

	local copied = ""
	for index, value in ipairs(content.regcontents) do
		if index > 1 then
			copied = copied .. "\n"
		end

		copied = copied .. value
	end

	wrapper.set_buffer(copied)
end

return M
