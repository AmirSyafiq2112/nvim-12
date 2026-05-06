local M = {}

vim.api.nvim_set_hl(0, "MyDiffAdd", { fg = "#32CD32" })
vim.api.nvim_set_hl(0, "MyDiffDelete", { fg = "#FF5555" })
vim.api.nvim_set_hl(0, "MyDiffChange", { fg = "#ffff00" })

local ns = vim.api.nvim_create_namespace("my_git_diff")

local is_tracked = function(file)
	vim.fn.system("git ls-files --error-unmatch " .. vim.fn.shellescape(file))
	return vim.v.shell_error == 0
end

local in_git_repo = function()
	vim.fn.system("git rev-parse --is-inside-work-tree")
	return vim.v.shell_error == 0
end

local add_signs = function(diff, bufnr)
	for _, hunk in ipairs(diff) do
		local start_old, count_old, start_new, count_new = unpack(hunk)

		if count_old == 0 and count_new > 0 then
			for i = 0, count_new - 1 do
				local lnum = start_new + i - 1 -- 0-indexed

				vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
					sign_text = "│", -- `▎`, `▏`, `│`,`┃`
					sign_hl_group = "MyDiffAdd",
				})
			end
		elseif count_old > 0 and count_new == 0 then
			local lnum = (start_new == 0) and 0 or (start_new - 1)

			vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
				sign_text = "│",
				sign_hl_group = "MyDiffDelete",
			})
		elseif count_old > 0 and count_new > 0 then
			for i = 0, count_new - 1 do
				local lnum = start_new + i - 1

				vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, 0, {
					sign_text = "│",
					sign_hl_group = "MyDiffChange",
				})
			end
		end
	end
end

local get_diff = function()
	local bufnr = vim.api.nvim_get_current_buf()
	-- local file = vim.fn.expand("%"):gsub("\\", "/")
	local file = vim.api.nvim_buf_get_name(bufnr)
	file = vim.fn.fnamemodify(file, ":.")

	if file == "" then
		return
	end

	file = file:gsub("\\", "/")

	if not in_git_repo() then
		return
	end

	local git_version

	if not is_tracked(file) then
		git_version = ""
	else
		git_version = vim.fn.system("git show HEAD:" .. file)
	end

	local current_version = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local diff = vim.text.diff(git_version, current_version, { result_type = "indices" })

	-- print(vim.inspect(diff))

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	vim.schedule(function()
		add_signs(diff, bufnr)
	end)
end

vim.api.nvim_create_user_command("GetDiff", get_diff, {})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	callback = get_diff,
})

return M
