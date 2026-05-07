local telescope = require("telescope")
local ivy_theme = { theme = "ivy" }
local cursor_theme = { theme = "cursor" }

telescope.setup({
    pickers = {
        find_files = ivy_theme,
        help_tags = ivy_theme,
        live_grep = ivy_theme,
        lsp_references = ivy_theme,
        buffers = ivy_theme,
        diagnostics = ivy_theme,
    },
    extensions = {
        fzf = {},
    },
    defaults = {
        file_ignore_patterns = {
            "node_modules",
        },
    },
})

telescope.load_extension("fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fi", function()
    builtin.find_files({
        hidden = true,
        no_ignore = true,
    })
end, { desc = "Telescope find hidden files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find Diagnostic" })
vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>en", function()
    builtin.find_files({
        cwd = vim.fn.stdpath("config"),
    })
end)
vim.keymap.set("n", "<leader>ep", function()
    builtin.find_files({
        cwd = vim.fn.stdpath("data"),
    })
end)
vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols)

require("config.telescope.multigrep").setup()
