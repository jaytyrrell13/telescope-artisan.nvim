local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
  return
end

local artisan = require('artisan.artisan')
local config = require('artisan.config')

return telescope.register_extension({
  setup = config.setup,
  exports = {
    artisan = artisan.run,
  },
})
