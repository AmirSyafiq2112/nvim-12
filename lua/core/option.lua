vim.opt.termguicolors = true
vim.cmd.colorscheme("catppuccin")
vim.opt.clipboard = { "unnamedplus" }
vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.fillchars = { eob = " " }
-- vim.opt.iskeyword:append("-")

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = false
vim.opt.wrap = true

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false

-- backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true

-- folding mapping (for nvim-ufo) in plugin/ufo

vim.opt.splitbelow = true
vim.opt.splitright = true

-- fold
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.o.winborder = "rounded"
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
