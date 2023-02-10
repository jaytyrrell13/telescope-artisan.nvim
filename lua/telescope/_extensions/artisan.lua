local json = require('json')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local previewers = require('telescope.previewers')
local action_state = require('telescope.actions.state')
-- local utils = require('telescope.utils')
local entry_display = require('telescope.pickers.entry_display')
local Path = require('plenary.path')

local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugins requires nvim-telescope/telescope.nvim')
  return
end

local displayer = entry_display.create({
  separator = ' ',
  items = {
    { width = 24 },
    { remaining = true },
  },
})

local make_display = function(entry)
  return displayer({
    entry.value.command,
    entry.value.description,
  })
end

local artisan_fn = function(opts)
  opts = opts or {}

  local cwd = vim.fn.getcwd()
  local artisan_path = Path:new(cwd, 'artisan')
  if not artisan_path:exists() then
    vim.notify('Could not find artisan executable', vim.log.levels.WARN)
    return nil
  end

  local commands = {}
  local jsonCommandsList = vim.fn.system('php artisan --format=json')

  local j = json.decode(jsonCommandsList)

  for _, value in ipairs(j.commands) do
    if value.hidden ~= true then
      table.insert(commands, {
        command = value.name,
        description = value.description,
        usage = value.usage,
        arguments = value.definition.arguments,
        options = value.definition.options,
      })
    end
  end

  pickers
    .new(opts, {
      prompt_title = 'Laravel Artisan',
      finder = finders.new_table({
        results = commands,
        entry_maker = function(entry)
          return {
            value = entry,
            display = make_display,
            ordinal = entry.command,
          }
        end,
      }),
      previewer = previewers.new_buffer_previewer({
        define_preview = function(self, entry)
          local values = { 'Description:' }
          table.insert(values, entry.value.description)
          table.insert(values, '')

          table.insert(values, 'Usage:')
          for _, value in pairs(entry.value.usage) do
            table.insert(values, value)
          end

          -- If arguments is not an empty table
          if next(entry.value.arguments) then
            table.insert(values, '')
            table.insert(values, 'Arguments')

            for _, value in pairs(entry.value.arguments) do
              local argument = value.name
              if not value.is_required then
                argument = '[' .. argument .. ']'
              end
              table.insert(values, argument .. '  ' .. value.description)
            end
          end

          table.insert(values, '')
          table.insert(values, 'Options')

          for _, value in pairs(entry.value.options) do
            local option = ''

            if value.shortcut ~= '' then
              option = value.shortcut .. ', '
            end

            table.insert(values, option .. value.name .. '  ' .. value.description)
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, values)
        end,
      }),
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(bufnr, map)
        local execute_cmd = function()
          local selection = action_state.get_selected_entry()
          actions.close(bufnr)
          vim.cmd('!php artisan ' .. selection.value.command)
          return true
        end

        map('i', '<C-e>', execute_cmd)
        map('n', 'e', execute_cmd)

        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(bufnr)

          vim.ui.input(
            { prompt = 'Enter arguments for "php artisan ' .. selection.value.command .. '": ' },
            function(msg)
              msg = msg or ''

              vim.cmd('!php artisan ' .. selection.value.command .. ' ' .. msg)
            end
          )
        end)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    artisan = artisan_fn,
  },
})
