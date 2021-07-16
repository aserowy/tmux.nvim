local logging = require("tmux.configuration.logging")
local options = require("tmux.configuration.options")
local validate = require("tmux.configuration.validate")
local wrapper = require("tmux.wrapper")

local M = {
    options = options,
    logging = logging,
}

function M.setup(opts, logs)
    M.options.set(vim.tbl_deep_extend("force", {}, M.options, opts or {}))
    M.logging.set(vim.tbl_deep_extend("force", {}, M.logging, logs or {}))

    validate.options(wrapper.version, M.options)
end

return M
