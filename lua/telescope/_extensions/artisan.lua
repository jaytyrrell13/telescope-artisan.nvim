local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
  return
end

local artisan = require('artisan')

return telescope.register_extension({
  exports = {
    artisan = artisan,
  },
})
