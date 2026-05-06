local M = {}

local diff = require("gitgutter.diff")
local signs = require("gitgutter.signs")

-- Default config
M.config = {
	enabled = true,
	signs = {
		add = { text = "│", color = "#1D9E75" }, -- green
		delete = { text = "│", color = "#E24B4A" }, -- red
		change = { text = "│", color = "#EF9F27" }, -- amber
	},
}

local function define_highlights(cfg)
	vim.api.nvim_set_hl(0, "GitGutterAdd", { fg = cfg.signs.add.color })
	vim.api.nvim_set_hl(0, "GitGutterDelete", { fg = cfg.signs.delete.color })
	vim.api.nvim_set_hl(0, "GitGutterChange", { fg = cfg.signs.change.color })
end

-- Update signs for the current buffer
function M.update(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local filepath = vim.api.nvim_buf_get_name(bufnr)

	-- Skip unnamed or non-file buffers
	if filepath == "" then
		return
	end

	diff.get_hunks(filepath, bufnr, function(hunks)
		-- Schedule back on the main thread (jobs run async)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				signs.render(bufnr, hunks, M.config)
			end
		end)
	end)
end

-- Call this from your init.lua: require("gitgutter").setup()
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	define_highlights(M.config)

	-- Make sure the sign column is always visible (at least 1 wide)
	vim.opt.signcolumn = "yes"

	-- Autocommand group — clears itself on re-source
	local augroup = vim.api.nvim_create_augroup("GitGutter", { clear = true })

	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "BufEnter" }, {
		group = augroup,
		callback = function(ev)
			M.update(ev.buf)
		end,
	})

	-- Re-apply highlights if colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = augroup,
		callback = function()
			define_highlights(M.config)
		end,
	})
end

return M
