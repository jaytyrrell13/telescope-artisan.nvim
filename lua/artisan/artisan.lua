local json = require('json')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local previewers = require('telescope.previewers')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local Path = require('plenary.path')
local strategies = require('artisan.strategies')

local M = {}

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

M.run = function(opts)
  local cwd = vim.fn.getcwd()
  local artisan_path = Path:new(cwd, 'artisan')
  if not artisan_path:exists() then
    vim.notify('Could not find artisan executable', vim.log.levels.WARN)
    return nil
  end

  local commands = {}
  local artisanCommandsList = vim.fn.system('php artisan --format=json')
  local artisanCommands = json.decode(artisanCommandsList)
  for _, cmd in ipairs(artisanCommands.commands) do
    if cmd.hidden ~= true then
      table.insert(commands, {
        command = cmd.name,
        description = cmd.description,
        usage = cmd.usage,
        arguments = cmd.definition.arguments,
        options = cmd.definition.options,
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
          local preview = { 'Description:' }
          table.insert(preview, entry.value.description)
          table.insert(preview, '')

          table.insert(preview, 'Usage:')
          for _, usage in pairs(entry.value.usage) do
            table.insert(preview, usage)
          end

          if vim.tbl_isempty(entry.value.arguments) then
            table.insert(preview, '')
            table.insert(preview, 'Arguments')

            for _, argument in pairs(entry.value.arguments) do
              local name = argument.name
              if not argument.is_required then
                name = '[' .. name .. ']'
              end
              table.insert(preview, name .. '  ' .. argument.description)
            end
          end

          table.insert(preview, '')
          table.insert(preview, 'Options')

          for _, option in pairs(entry.value.options) do
            local name = option.name
            if option.shortcut ~= '' then
              name = option.shortcut .. ', ' .. name
            end

            table.insert(preview, name .. '  ' .. option.description)
          end

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview)
        end,
      }),
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(bufnr, map)
        local execute_cmd = function()
          local selection = action_state.get_selected_entry()
          actions.close(bufnr)

          strategies.execute(selection.value.command)

          return true
        end

        map('i', '<C-e>', execute_cmd)
        map('n', 'e', execute_cmd)

        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(bufnr)

          vim.ui.input(
            { prompt = 'Enter arguments for "php artisan ' .. selection.value.command .. '": ' },
            function(input)
              if input then
                strategies.execute(selection.value.command .. ' ' .. input)
              end
            end
          )
        end)
        return true
      end,
    })
    :find()
end

return M
