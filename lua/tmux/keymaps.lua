local api = vim.api

local keymaps = {}
keymaps.register = function(scope, mappings, options)
    local opts
    if options == nil then
        opts = {
            nowait = true,
            silent = true,
            noremap = true,
        }
    else
        opts = options
    end

    for key, value in pairs(mappings) do
        api.nvim_set_keymap(scope, key, value, opts)
    end
end

return keymaps
