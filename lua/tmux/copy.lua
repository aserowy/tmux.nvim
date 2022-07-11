local options = require("tmux.configuration").options
local tmux = require("tmux.tmux")

local function rtc(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function sync_register(index, buffer_name)
    vim.fn.setreg(index, tmux.get_buffer(buffer_name))
end

local function sync_unnamed_register(buffer_name)
    if buffer_name ~= nil and buffer_name ~= "" then
        sync_register("@", buffer_name)
    end
end

local function sync_registers(passed_key)
    local ignore_buffers = options.copy_sync.ignore_buffers
    local offset = options.copy_sync.register_offset

    local first_buffer_name = ""
    for k, v in ipairs(tmux.get_buffer_names()) do
        if not ignore_buffers[v] then
            if k == 1 then
                first_buffer_name = v
            end
            if k >= 11 - offset then
                break
            end
            sync_register(tostring(k - 1 + offset), v)
        end
    end

    if options.copy_sync.sync_unnamed then
        sync_unnamed_register(first_buffer_name)
    end

    if passed_key ~= nil and passed_key ~= "" then
        return rtc(passed_key)
    end
end

local function resolve_content(regtype, regcontents)
    local result = ""
    for index, value in ipairs(regcontents) do
        if index > 1 then
            result = result .. "\n"
        end
        result = result .. value
    end

    if regtype == "V" then
        result = result .. "\n"
    end

    return result
end

local M = {
    sync_registers = sync_registers,
}

function M.setup()
    if not tmux.is_tmux or not options.copy_sync.enable then
        return
    end

    local agroup = vim.api.nvim_create_augroup('tmux', {})

    vim.api.nvim_create_autocmd('TextYankPost', {
        group = agroup,
        callback = function()
            M.post_yank(vim.v.event)
        end
    })

    vim.api.nvim_create_autocmd({'CmdlineEnter', 'VimEnter'}, {
        group = agroup,
        callback = function()
            M.sync_registers()
        end
    })

    vim.api.nvim_create_autocmd('CmdwinEnter', {
        group = agroup,
        pattern = ':',
        callback = function()
            M.sync_registers()
        end
    })

    local function map(m, l, r)
        vim.keymap.set(m, l, r, { expr = true })
    end

    map('n', '"', function() M.sync_registers('"') end)
    map('n', "p", function() M.sync_registers('p') end)
    map('n', "P", function() M.sync_registers('P') end)

    -- double C-r to prevent injection:
    -- https://vim.fandom.com/wiki/Pasting_registers#In_insert_and_command-line_modes
    map({'i', 'c'}, "<C-r>", function() M.sync_registers("<C-r><C-r>") end)

    if options.copy_sync.sync_clipboard then
        vim.g.clipboard = {
            name = "tmuxclipboard",
            copy = {
                ["+"] = "tmux load-buffer -w -",
                ["*"] = "tmux load-buffer -w -",
            },
            paste = {
                ["+"] = "tmux save-buffer -",
                ["*"] = "tmux save-buffer -",
            },
        }
    end
end

function M.post_yank(content)
    if content.regname ~= "" then
        return
    end

    if content.operator ~= "y" and not options.copy_sync.sync_deletes then
        return
    end

    local buffer_content = resolve_content(content.regtype, content.regcontents)

    tmux.set_buffer(buffer_content, options.copy_sync.redirect_to_clipboard)
end

return M
