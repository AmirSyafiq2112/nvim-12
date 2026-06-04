local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true)
	end

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, true, win_config)

	return {
		buf = buf,
		win = win,
	}
end

local toggle_terminal = function()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		state.floating = create_floating_window({ buf = state.floating.buf })

		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			vim.cmd.terminal()
		end

		vim.cmd("startinsert")
	else
		vim.api.nvim_win_hide(state.floating.win)
	end
end

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function(args)
		local config = vim.api.nvim_win_get_config(0)

		if config.relative == "" then
			return
		end

		vim.keymap.set("t", "<Esc><Esc>", function()
			vim.cmd("stopinsert")
			vim.api.nvim_win_close(0, false)
		end, { buffer = args.buf })
	end,
})

local kill_terminal = function()
	if vim.api.nvim_buf_is_valid(state.floating.buf) then
		local job_id = vim.b[state.floating.buf].terminal_job_id

		if job_id then
			vim.fn.jobstop(job_id)
		end

		vim.api.nvim_buf_delete(state.floating.buf, { force = true })

		state.floating.buf = -1
		state.floating.win = -1
	end
end

vim.api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<leader>tt", toggle_terminal)
vim.keymap.set({ "n", "t" }, "<leader>tk", kill_terminal)
