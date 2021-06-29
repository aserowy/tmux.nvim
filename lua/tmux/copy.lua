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
		if k >= 11 then
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

	vim.cmd([[
        if !exists("tmux_autocommands_loaded")
            let tmux_autocommands_loaded = 1
            let PostYank = luaeval('require("tmux").post_yank')
            autocmd TextYankPost * call PostYank(v:event)
        endif
    ]])

	_G.tmux = {
		yank = sync_registers,
	}

	keymaps.register("n", {
		['"'] = [[v:lua.tmux.yank('"')]],
	}, { expr = true, noremap = true })

	keymaps.register("i", {
		["<C-r>"] = [[v:lua.tmux.yank("<C-r>")]],
	}, { expr = true, noremap = true })

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

function M.post_yank(content)
	--[[ {
    ^I['visual'] = true,
    ^I['inclusive'] = true,
    ^I['regtype'] = 'V',
    ^I['regcontents'] = {
    ^I^I[1] = '^Ivim.cmd([[ ',
    ^I^I[2] = '        if !exists("tmux_autocommands_loaded")',
    ^I^I[3] = '            let tmux_autocommands_loaded = 1'
    ^I},
    ^I['regname'] = '',
    ^I['operator'] = 'y'
    } ]]
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
