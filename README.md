# Telescope artisan

This plugin adds a Laravel Artisan picker to the [Telescope plugin](https://github.com/nvim-telescope/telescope.nvim) for Neovim.

## Requirements

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (required)
- Laravel project

## Setup

Install the plugin using your favorite package manager.

```lua
use({ 'jaytyrrell13/telescope-artisan.nvim' })
```

Then tell Telescope to load the extension:

```lua
require('telescope').setup({})
require('telescope').load_extension('artisan')
```

## Usage

```lua
require'telescope'.extensions.artisan.artisan{}
vim.cmd [[ Telescope artisan ]]
```

or

```vim
:Telescope artisan
```
