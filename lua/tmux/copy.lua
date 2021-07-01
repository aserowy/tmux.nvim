local cfg = require("tmux.configuration")
local keymaps = require("tmux.keymaps")
local log = require("tmux.log")
local wrapper = require("tmux.wrapper")

local function rtc(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function sync_register(index, buffer_name)
	local content = wrapper.get_buffer(buffer_name)
	vim.fn.setreg(index, content)
end

local function sync_unnamed_register(buffer_name)
	if buffer_name ~= nil and buffer_name ~= "" then
		sync_register("@", buffer_name)
	end
end

local function sync_registers(passed_key)
	log.debug(string.format("sync_registers: %s", passed_key))

	local offset = cfg.options.copy_sync.register_offset
	local first_buffer_name = ""
	for k, v in ipairs(wrapper.get_buffer_names()) do
		if k == 1 then
			first_buffer_name = v
		end
		if k >= 11 - offset then
			break
		end
		sync_register(tostring(k - 1 + offset), v)
	end

	sync_unnamed_register(first_buffer_name)

	if passed_key ~= nil and passed_key ~= "" then
		return rtc(passed_key)
	end
end

local M = {
	sync_registers = sync_registers,
}

function M.setup()
	if not wrapper.is_tmux or not cfg.options.copy_sync.enable then
		return
	end

	vim.cmd([[
        if !exists("tmux_autocommands_loaded")
            let tmux_autocommands_loaded = 1
            let PostYank = luaeval('require("tmux").post_yank')
            let SyncRegisters = luaeval('require("tmux").sync_registers')
            autocmd TextYankPost * call PostYank(v:event)
            autocmd CmdlineEnter * call SyncRegisters()
            autocmd CmdwinEnter : call SyncRegisters()
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

	-- double C-r to prevent injection:
	-- https://vim.fandom.com/wiki/Pasting_registers#In_insert_and_command-line_modes
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
end

function M.post_yank(content)
	log.debug(content)

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

	if content.regtype == "V" then
		copied = copied .. "\n"
	end

	log.debug(copied)

	wrapper.set_buffer(copied)
end

return M
