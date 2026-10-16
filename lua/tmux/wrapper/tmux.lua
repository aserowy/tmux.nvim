local vim = vim

local log = require("tmux.log")

local tmux_directions = { h = "L", j = "D", k = "U", l = "R" }
local tmux_swap_directions = { h = "left", j = "down", k = "up", l = "right" }

local function get_tmux()
    return os.getenv("TMUX")
end

local function get_tmux_pane()
    return os.getenv("TMUX_PANE")
end

local function get_socket()
    return vim.split(get_tmux(), ",")[1]
end

local M = {
    is_tmux = false,
}

-- run tmux directly, as spawning a shell for every call is noticeably slow
function M.execute(args, stdin)
    local command = { "tmux", "-S", get_socket() }
    vim.list_extend(command, args)

    return vim.system(command, { text = true, stdin = stdin }):wait().stdout
end

local function get_version()
    local result = M.execute({ "-V" })
    local version = result:sub(result:find(" ") + 1)

    return version:gsub("[^%.%w]", "")
end

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
    M.execute({ "select-pane", "-t", get_tmux_pane(), "-" .. tmux_directions[direction] })
    vim.o.laststatus = vim.o.laststatus -- reset statusline as it sometimes disappear (#105)
end

function M.window_index()
    return M.execute({ "display-message", "-p", "#{window_index}" })
end

function M.base_index()
    return M.execute({ "display-message", "-p", "#{base-index}" })
end

function M.window_end_flag()
    return M.execute({ "display-message", "-p", "#{window_end_flag}" }) == "0"
end

function M.window_start_flag()
    return M.window_index() == M.base_index()
end

function M.select_window(direction)
    M.execute({ "select-window", "-" .. direction })
    vim.o.laststatus = vim.o.laststatus -- reset statusline as it sometimes disappear (#105)
end

function M.get_buffer(name)
    return M.execute({ "show-buffer", "-b", name })
end

function M.get_buffer_names()
    local buffers = M.execute({ "list-buffers", "-F", "#{buffer_name}" })

    local result = {}
    for line in buffers:gmatch("([^\n]+)\n?") do
        table.insert(result, line)
    end

    return result
end

function M.get_current_pane_id()
    local pane = get_tmux_pane()
    return pane and tonumber(pane:sub(2)) or nil
end

function M.get_window_layout()
    return M.execute({ "display-message", "-p", "#{window_layout}" })
end

-- one call for both, as spawning tmux is the slow part
function M.get_window_zoom_and_layout()
    local output = M.execute({ "display-message", "-p", "#{window_zoomed_flag} #{window_layout}" })
    return output:sub(1, 1) == "1", output:sub(3)
end

function M.resize(direction, step)
    M.execute({ "resize-pane", "-t", get_tmux_pane(), "-" .. tmux_directions[direction], tostring(step) })
end

function M.swap(direction)
    M.execute({ "swap-pane", "-t", get_tmux_pane(), "-s", "{" .. tmux_swap_directions[direction] .. "-of}" })
end

function M.set_buffer(content, sync_clipboard)
    if sync_clipboard then
        M.execute({ "load-buffer", "-w", "-" }, content)
    else
        M.execute({ "load-buffer", "-" }, content)
    end
end

return M
