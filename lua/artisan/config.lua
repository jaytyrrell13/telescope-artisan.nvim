local M = {}

M.defaults = {
  strategy = 'neovim',
}

M.opts = {}

function M.setup(opts)
  opts = opts or {}

  M.opts = vim.tbl_deep_extend('force', M.defaults, opts)
end

return M
