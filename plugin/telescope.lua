local telescope = require('telescope')
local ivy_theme = { theme = "ivy", }
local cursor_theme = { theme = "cursor", }

telescope.setup({
    pickers = {
        find_files = ivy_theme,
        help_tags = ivy_theme,
        live_grep = ivy_theme,
        lsp_references = ivy_theme
    },
    extensions = {
        fzf = {}
    }
})

telescope.load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
-- vim.keymap.set('n', '<leader>hf', function()
--     builtin.find_files {
--         hidden = true,
--     }
-- end,
-- { desc = 'Telescope find hidden files' })
-- vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>gr', builtin.lsp_references, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>en', function()
    builtin.find_files {
        cwd = vim.fn.stdpath("config")
    }
end)
vim.keymap.set('n', '<leader>ep', function()
    builtin.find_files {
        cwd = vim.fn.stdpath("data")
    }
end)


require "config.telescope.multigrep".setup()
