vim.g.mapleader = " "

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>re', '<cmd>restart<CR>')

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("x", "<leader>p", "\"_dP")
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Mini
-- vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
-- vim.keymap.set('n', '<leader>h', ":Pick help<CR>")

-- Oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {clear = true}),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Quickfix
local function qf_next()
  local qf = vim.fn.getqflist({ winid = 0 })
  if qf.winid ~= 0 then
    vim.cmd("cnext")
  else
    -- fallback behavior (optional)
    vim.cmd("normal! <C-j>")
  end
end

local function qf_prev()
  local qf = vim.fn.getqflist({ winid = 0 })
  if qf.winid ~= 0 then
    vim.cmd("cprev")
  else
    vim.cmd("normal! <C-k>")
  end
end

local function qf_close()
  local qf = vim.fn.getqflist({ winid = 0 })
  if qf.winid ~= 0 then
    vim.cmd("cclose")
  else
    vim.cmd("normal! q")
  end
end

vim.keymap.set('n', '<C-j>', qf_next)
vim.keymap.set('n', '<C-k>', qf_prev)
vim.keymap.set('n', 'q', qf_close)
