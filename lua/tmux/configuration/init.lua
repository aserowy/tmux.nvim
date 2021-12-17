local log = require("tmux.log")
local logging = require("tmux.configuration.logging")
local options = require("tmux.configuration.options")
local validate = require("tmux.configuration.validate")
local tmux = require("tmux.wrapper.tmux")

local M = {
    options = options,
    logging = logging,
}

function M.setup(opts, logs)
    M.logging.set(vim.tbl_deep_extend("force", {}, M.logging, logs or {}))

    log.debug("configuration injected: ", opts)
    M.options.set(vim.tbl_deep_extend("force", {}, M.logging, opts or {}))

    if tmux.is_tmux then
        validate.options(tmux.version, M.options)
    end
end

return M
