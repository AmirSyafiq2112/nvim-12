local M = {}

local ns = vim.api.nvim_create_namespace("opencode_multifile_edit_review")
vim.api.nvim_set_hl(0, "OpencodeReviewAccept", { fg = "#a6da95", bg = "NONE", default = true })
vim.api.nvim_set_hl(0, "OpencodeReviewReject", { fg = "#ed8796", bg = "NONE", default = true })

local state = nil
local pending_review = nil
local quickmark_suspended = false

local function suspend_quickmark()
	local ok, quickmark = pcall(require, "quickmark")
	if ok and quickmark.suspend then
		quickmark.suspend("opencode")
		quickmark_suspended = true
	end
end

local function resume_quickmark()
	if not quickmark_suspended then
		return
	end

	quickmark_suspended = false
	local ok, quickmark = pcall(require, "quickmark")
	if ok and quickmark.resume then
		quickmark.resume("opencode")
	end
end

local function split_lines(text)
	return vim.split(text or "", "\n", { plain = true })
end

local function display_path(path)
	path = path:gsub("^a/", ""):gsub("^b/", "")
	return path
end

local function normalized_path(path)
	return vim.fn.fnamemodify(path, ":~:.")
end

local function parse_diff(diff, fallback_filepaths)
	local files = {}
	local current = nil

	local function push_current()
		if current then
			current.lines = current.lines or {}
			table.insert(files, current)
			current = nil
		end
	end

	for _, line in ipairs(split_lines(diff)) do
		local left, right = line:match("^diff %-%-git%s+a/(.-)%s+b/(.+)$")
		local indexed = line:match("^Index:%s+(.+)$")
		if left or right then
			push_current()
			local path = right ~= "/dev/null" and right or left
			current = { path = normalized_path(display_path(path)), lines = { line } }
		elseif indexed then
			push_current()
			current = { path = normalized_path(indexed), lines = { line } }
		elseif current then
			table.insert(current.lines, line)
		else
			local created = line:match("^%+%+%+%s+b/(.+)$")
			local deleted = line:match("^%-%-%-%s+a/(.+)$")
			local path = created or deleted
			if path then
				current = { path = normalized_path(display_path(path)), lines = { line } }
			end
		end
	end

	push_current()

	if #files > 0 then
		return files
	end

	local lines = split_lines(diff)
	for _, path in ipairs(fallback_filepaths) do
		table.insert(files, {
			path = normalized_path(path),
			lines = vim.list_extend(
				{ "Could not split this patch by file. Showing the full edit diff.", "" },
				vim.deepcopy(lines)
			),
		})
	end

	return files
end

local function close_state(restore)
	if not state then
		return
	end

	local old = state
	state = nil

	if old.list_win and vim.api.nvim_win_is_valid(old.list_win) then
		vim.api.nvim_win_close(old.list_win, true)
	end

	if old.preview_win and vim.api.nvim_win_is_valid(old.preview_win) then
		if restore and old.original_buf and vim.api.nvim_buf_is_valid(old.original_buf) then
			vim.api.nvim_win_set_buf(old.preview_win, old.original_buf)
		end
	end

	if old.preview_buf and vim.api.nvim_buf_is_valid(old.preview_buf) then
		vim.api.nvim_buf_delete(old.preview_buf, { force = true })
	end

	if old.original_win and vim.api.nvim_win_is_valid(old.original_win) then
		vim.api.nvim_set_current_win(old.original_win)
	end

	resume_quickmark()
end

local function render_list()
	if not state or not vim.api.nvim_buf_is_valid(state.list_buf) then
		return
	end

	local footer_count = 10
	local header_count = 4
	local list_count = math.max(1, state.height - header_count - footer_count)
	local max_start = math.max(1, #state.files - list_count + 1)
	local start_index = math.min(max_start, math.max(1, state.index - math.floor(list_count / 2)))
	local end_index = math.min(#state.files, start_index + list_count - 1)
	local has_above = start_index > 1
	local has_below = end_index < #state.files
	local scroll_hint = (has_above and "↑" or " ") .. (has_below and "↓" or " ")

	local lines = {
		"OpenCode edit request",
		("%d files changed"):format(#state.files),
		("Showing %d-%d / %d %s"):format(start_index, end_index, #state.files, scroll_hint),
		"",
	}

	for index = start_index, end_index do
		local file = state.files[index]
		local prefix = index == state.index and "> " or "  "
		table.insert(lines, prefix .. file.path)
	end
	for _ = #lines + 1, header_count + list_count do
		table.insert(lines, "")
	end

	table.insert(lines, "")
	table.insert(lines, "Action:")
	local action_line = #lines + 1
	local action_text = state.action == "accept" and "[Accept]   Reject" or " Accept   [Reject]"
	table.insert(lines, action_text)
	table.insert(lines, "")
	table.insert(lines, "help:")
	table.insert(lines, "")
	table.insert(lines, "j/k: files")
	table.insert(lines, "h/l: action")
	table.insert(lines, "<CR>: choose action")
	table.insert(lines, "q: close")

	vim.bo[state.list_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.list_buf, 0, -1, false, lines)
	vim.bo[state.list_buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(state.list_buf, ns, 0, -1)
	for line_index = header_count + 1, header_count + list_count do
		local file_index = start_index + (line_index - header_count - 1)
		if file_index == state.index then
			vim.api.nvim_buf_add_highlight(state.list_buf, ns, "Visual", line_index - 1, 0, -1)
		end
	end

	local accept_start = action_text:find("Accept", 1, true)
	local reject_start = action_text:find("Reject", 1, true)
	if accept_start then
		vim.api.nvim_buf_add_highlight(
			state.list_buf,
			ns,
			"OpencodeReviewAccept",
			action_line - 1,
			accept_start - 1,
			accept_start + 5
		)
	end
	if reject_start then
		vim.api.nvim_buf_add_highlight(
			state.list_buf,
			ns,
			"OpencodeReviewReject",
			action_line - 1,
			reject_start - 1,
			reject_start + 5
		)
	end
end

local function set_preview_keymaps(buf)
	local opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "q", function()
		close_state(true)
	end, vim.tbl_extend("force", opts, { desc = "Close OpenCode edit review" }))
	vim.keymap.set("n", "<Esc>", function()
		close_state(true)
	end, vim.tbl_extend("force", opts, { desc = "Close OpenCode edit review" }))
end

local function render_preview()
	if not state or not state.preview_win or not vim.api.nvim_win_is_valid(state.preview_win) then
		return
	end

	local file = state.files[state.index]
	local old_buf = state.preview_buf
	local buf = vim.api.nvim_create_buf(false, true)
	state.preview_buf = buf

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = "diff"
	vim.api.nvim_buf_set_name(buf, "opencode-edit-review://" .. file.path)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, file.lines)
	vim.bo[buf].modifiable = false
	set_preview_keymaps(buf)

	vim.api.nvim_win_set_buf(state.preview_win, buf)
	if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
		vim.api.nvim_buf_delete(old_buf, { force = true })
	end
	vim.wo[state.preview_win].wrap = false
	vim.wo[state.preview_win].cursorline = true
end

local function move_selection(delta)
	if not state then
		return
	end

	state.index = ((state.index - 1 + delta) % #state.files) + 1
	render_preview()
	render_list()
end

local function set_action(action)
	if not state then
		return
	end

	state.action = action
	render_list()
end

local function confirm_action()
	if not state then
		return
	end

	local permit = state.permit
	local reply = state.action == "accept" and "once" or "reject"
	pending_review = nil
	close_state(true)
	permit(reply)
end

local function set_list_keymaps(buf)
	local opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "j", function()
		move_selection(1)
	end, vim.tbl_extend("force", opts, { desc = "Next OpenCode edit file" }))
	vim.keymap.set("n", "k", function()
		move_selection(-1)
	end, vim.tbl_extend("force", opts, { desc = "Previous OpenCode edit file" }))
	vim.keymap.set("n", "h", function()
		set_action("accept")
	end, vim.tbl_extend("force", opts, { desc = "Select accept" }))
	vim.keymap.set("n", "l", function()
		set_action("reject")
	end, vim.tbl_extend("force", opts, { desc = "Select reject" }))
	vim.keymap.set(
		"n",
		"<CR>",
		confirm_action,
		vim.tbl_extend("force", opts, { desc = "Confirm OpenCode edit action" })
	)
	vim.keymap.set("n", "q", function()
		close_state(true)
	end, vim.tbl_extend("force", opts, { desc = "Close OpenCode edit review" }))
	vim.keymap.set("n", "<Esc>", function()
		close_state(true)
	end, vim.tbl_extend("force", opts, { desc = "Close OpenCode edit review" }))
end

---@param opts { diff: string, filepaths: string[], permit: fun(reply: string) }
function M.open(opts)
	close_state(true)
	pending_review = opts

	local original_win = vim.api.nvim_get_current_win()
	local original_buf = vim.api.nvim_get_current_buf()
	local files = parse_diff(opts.diff, opts.filepaths)
	if #files == 0 then
		vim.notify("OpenCode edit request did not include diff content", vim.log.levels.WARN, { title = "opencode" })
		return
	end
	suspend_quickmark()

	local columns = vim.o.columns
	local lines = vim.o.lines
	local width = math.min(48, math.max(36, math.floor(columns * 0.28)))
	local height = math.min(40, math.max(20, #files + 14))
	local row = math.max(0, lines - height - 4)
	local col = math.max(0, columns - width - 2)

	local list_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[list_buf].buftype = "nofile"
	vim.bo[list_buf].bufhidden = "wipe"
	vim.bo[list_buf].swapfile = false
	vim.bo[list_buf].filetype = "opencode-edit-review"

	local list_win = vim.api.nvim_open_win(list_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " OpenCode ",
		title_pos = "center",
	})

	state = {
		files = files,
		index = 1,
		action = "accept",
		permit = opts.permit,
		original_win = original_win,
		original_buf = original_buf,
		preview_win = original_win,
		preview_buf = nil,
		list_buf = list_buf,
		list_win = list_win,
		width = width,
		height = height,
	}

	set_list_keymaps(list_buf)
	render_preview()
	render_list()
	vim.api.nvim_set_current_win(list_win)
end

function M.close()
	pending_review = nil
	close_state(true)
end

function M.reopen()
	if state and state.list_win and vim.api.nvim_win_is_valid(state.list_win) then
		vim.api.nvim_set_current_win(state.list_win)
		return true
	end

	if not pending_review then
		vim.notify("No pending OpenCode edit review to reopen", vim.log.levels.INFO, { title = "opencode" })
		return false
	end

	M.open(pending_review)
	return true
end

return M
