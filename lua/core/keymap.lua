vim.g.mapleader = " "

-- better behavior
vim.keymap.set("x", "p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Paste without yanking" })

-- better movement
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

-- Center Cursor
-- vim.keymap.set("n", "j", "jzzzv", { desc = "Down (centered)" })
-- vim.keymap.set("n", "k", "kzzzv", { desc = "Up (centered)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

vim.keymap.set("n", "<leader>o", ":update<CR> :source<CR>")
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>re", "<cmd>restart<CR>")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("x", "<leader>p", '"_dP')
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- Mini
-- vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
-- vim.keymap.set('n', '<leader>h', ":Pick help<CR>")

-- Oil
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
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

vim.keymap.set("n", "<C-j>", qf_next)
vim.keymap.set("n", "<C-k>", qf_prev)
vim.keymap.set("n", "q", qf_close)
-- toggle undo tree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {
	desc = "Toggle Undotree",
})

-- focus undo tree window (optional)
vim.keymap.set("n", "<leader>U", vim.cmd.UndotreeFocus, {
	desc = "Focus Undotree",
})

vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>")

vim.keymap.set("n", "<leader>th", "<cmd>set invhlsearch<CR>", { desc = "Toggle hlsearch" })

-- buffer
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "[B]uffer [N]ext" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "[B]uffer [P]revious" })
