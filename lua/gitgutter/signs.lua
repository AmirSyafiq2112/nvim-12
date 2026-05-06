local M = {}

-- Namespace: a unique ID that groups all our marks together
-- Makes it easy to clear them all at once
local ns = vim.api.nvim_create_namespace("gitgutter")

-- Highlight groups (defined in init.lua)
local hl_map = {
	add = "GitGutterAdd",
	delete = "GitGutterDelete",
	change = "GitGutterChange",
}

-- Clear all our marks in a buffer
function M.clear(bufnr)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

-- Place marks for a list of hunks: { { line=N, type="add"|"delete"|"change" }, ... }
function M.render(bufnr, hunks, cfg)
	M.clear(bufnr)

	local line_count = vim.api.nvim_buf_line_count(bufnr)

	for _, hunk in ipairs(hunks) do
		local lnum = hunk.line - 1 -- extmarks use 0-indexed lines
		if lnum >= 0 and lnum < line_count then
			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
				sign_text = cfg.signs[hunk.type].text,
				sign_hl_group = hl_map[hunk.type],
				priority = 10,
			})
		end
	end
end

return M
