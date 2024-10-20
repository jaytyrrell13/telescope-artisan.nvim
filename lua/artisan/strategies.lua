local config = require('artisan.config')

local M = {}

function M.basic(command)
  vim.cmd('!php artisan ' .. command)
end

function M.neovim(command)
  vim.cmd('botright new | terminal php artisan ' .. command)
end

function M.floaterm(command)
  vim.cmd('FloatermNew --autoclose=0 php artisan ' .. command)
end

function M.dispatch(command)
  vim.cmd('Dispatch php artisan ' .. command)
end

function M.dispatch_background(command)
  vim.cmd('Dispatch! php artisan ' .. command)
end

function M.execute(command)
  local strategy = config.opts.strategy

  if not M[strategy] then
    vim.notify('Unknown strategy "' .. config.opts.strategy .. '" for telescope-artisan.nvim', vim.log.levels.WARN)
    return
  end

  M[strategy](command)
end

return M
