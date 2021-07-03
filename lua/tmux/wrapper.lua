local vim = vim

local TMUX = os.getenv("TMUX")
local TMUX_PANE = os.getenv("TMUX_PANE")

local tmux_directions = {
	h = "L",
	j = "D",
	k = "U",
	l = "R",
}

local tmux_borders = {
	h = "left",
	j = "bottom",
	k = "top",
	l = "right",
}

local function get_socket()
	return vim.split(TMUX, ",")[1]
end

local function execute(arg, pre)
	local command = string.format("%s tmux -S %s %s", pre or "", get_socket(), arg)

	local handle = assert(io.popen(command), string.format("unable to execute: [%s]", command))
	local result = handle:read("*a")
	handle:close()

	return result
end

local M = {
	is_tmux = TMUX ~= nil,
}

function M.change_pane(direction)
	execute(string.format("select-pane -t '%s' -%s", TMUX_PANE, tmux_directions[direction]))
end

function M.get_buffer(name)
	return execute(string.format("show-buffer -b %s", name))
end

function M.get_buffer_names()
	local buffers = execute([[ list-buffers -F "#{buffer_name}" ]])

	local result = {}
	for line in buffers:gmatch("([^\n]+)\n?") do
		table.insert(result, line)
	end

	return result
end

function M.has_neighbor(direction)
	local command = string.format("display-message -p '#{pane_at_%s}'", tmux_borders[direction])

	return not execute(command):find("1")
end

function M.is_zoomed()
	return execute("display-message -p '#{window_zoomed_flag}'"):find("1")
end

function M.resize(direction)
	execute(string.format("resize-pane -t '%s' -%s 1", TMUX_PANE, tmux_directions[direction]))
end

function M.set_buffer(content, sync_clipboard)
	content = content:gsub("\\", "\\\\\\\\")
	content = content:gsub('"', '\\"')

	if sync_clipboard ~= nil and sync_clipboard then
		execute("load-buffer -w -", string.format('echo -n "%s" | ', content))
	else
		execute("load-buffer -", string.format('echo -n "%s" | ', content))
	end
end

return M
