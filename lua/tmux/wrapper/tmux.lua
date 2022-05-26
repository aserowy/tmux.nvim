local vim = vim

local log = require("tmux.log")

local tmux_directions = {
    h = "L",
    j = "D",
    k = "U",
    l = "R",
}

local function get_tmux()
    return os.getenv("TMUX")
end

local function get_tmux_pane()
    return os.getenv("TMUX_PANE")
end

local function get_socket()
    return vim.split(get_tmux(), ",")[1]
end

local function execute(arg, pre)
    local command = string.format("%s tmux -S %s %s", pre or "", get_socket(), arg)

    local handle = assert(io.popen(command), string.format("unable to execute: [%s]", command))
    local result = handle:read("*a")
    handle:close()

    return result
end

local function get_version()
    local result = execute("-V")
    local version = result:sub(result:find(" ") + 1)

    return version:gsub("[^%.%w]", "")
end

local M = {
    is_tmux = false,
}

function M.setup()
    M.is_tmux = get_tmux() ~= nil

    log.debug(M.is_tmux)

    if not M.is_tmux then
        return false
    end

    M.version = get_version()

    log.debug(M.version)

    return true
end

function M.change_pane(direction)
    execute(string.format("select-pane -t '%s' -%s", get_tmux_pane(), tmux_directions[direction]))
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

function M.get_current_pane_id()
    return tonumber(get_tmux_pane():sub(2))
end

function M.get_window_layout()
    return execute("display-message -p '#{window_layout}'")
end

function M.is_zoomed()
    return execute("display-message -p '#{window_zoomed_flag}'"):find("1")
end

function M.resize(direction, step)
    execute(string.format("resize-pane -t '%s' -%s %d", get_tmux_pane(), tmux_directions[direction], step))
end

function M.set_buffer(content, sync_clipboard)
    content = content:gsub("\\", "\\\\")
    content = content:gsub('"', '\\"')
    content = content:gsub("`", "\\`")
    content = content:gsub("%$", "\\$")

    if sync_clipboard ~= nil and sync_clipboard then
        execute("load-buffer -w -", string.format('printf "%%s" "%s" | ', content))
    else
        execute("load-buffer -", string.format('printf "%%s" "%s" | ', content))
    end
end

return M
