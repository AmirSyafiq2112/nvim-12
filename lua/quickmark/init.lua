local M = {}

local marks = {}
local MAX_MARKS = 5
local display_buf = nil
local display_win = nil
local display_hidden_for_qf = false
local display_hidden_for_opencode = false

local function get_formatted_path(filepath)
	local path = filepath:gsub("\\", "/")
	local parts = vim.split(path, "/", { plain = true })
	local filename = parts[#parts]

	local total_parents = #parts - 1
	local shown_parents = math.min(total_parents, 3)

	local result_parts = {}
	if total_parents > 3 then
		table.insert(result_parts, "..")
	end
	for i = total_parents - shown_parents + 1, total_parents do
		table.insert(result_parts, parts[i])
	end
	table.insert(result_parts, filename)
	return table.concat(result_parts, "/")
end

local function get_editor_dimensions()
	local ui = vim.api.nvim_list_uis()
	if #ui > 0 then
		return ui[1].width, ui[1].height
	end
	return vim.o.columns, math.max(1, vim.o.lines - vim.o.cmdheight)
end

local function close_display()
	if display_win and vim.api.nvim_win_is_valid(display_win) then
		vim.api.nvim_win_close(display_win, true)
	end
	display_buf = nil
	display_win = nil
end

local function update_display()
	close_display()

	if display_hidden_for_opencode then
		return
	end

	if #marks == 0 then
		return
	end

	local lines = {}
	local max_width = 0
	for i, filepath in ipairs(marks) do
		local formatted = get_formatted_path(filepath)
		local line = string.format("%d: %s", i, formatted)
		table.insert(lines, line)
		max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
	end

	local content_width = max_width + 4
	local content_height = #lines

	local editor_width, editor_height = get_editor_dimensions()
	local row = math.max(0, editor_height - content_height - 6)
	local col = math.max(0, editor_width - content_width - 2)

	display_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(display_buf, 0, -1, false, lines)

	display_win = vim.api.nvim_open_win(display_buf, false, {
		relative = "editor",
		width = content_width,
		height = content_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		zindex = 50,
	})

	vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = display_win })
	vim.api.nvim_set_option_value("cursorline", false, { win = display_win })
	vim.api.nvim_set_option_value("number", false, { win = display_win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = display_win })
	vim.api.nvim_set_option_value("signcolumn", "no", { win = display_win })
	vim.api.nvim_set_option_value("foldcolumn", "0", { win = display_win })
	vim.api.nvim_set_option_value("spell", false, { win = display_win })
	vim.api.nvim_set_option_value("wrap", false, { win = display_win })
	vim.api.nvim_set_option_value("list", false, { win = display_win })
end

function M.mark_file()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		vim.notify("Quickmark: No file path to mark", vim.log.levels.WARN)
		return
	end

	for _, mark in ipairs(marks) do
		if mark == filepath then
			vim.notify("Quickmark: File already marked", vim.log.levels.INFO)
			return
		end
	end

	if #marks < MAX_MARKS then
		table.insert(marks, filepath)
		update_display()
		return
	end

	local choices = {}
	for i, mark in ipairs(marks) do
		table.insert(choices, string.format("%d: %s", i, get_formatted_path(mark)))
	end

	vim.ui.select(choices, {
		prompt = "Quickmark: All slots full. Replace which file?",
	}, function(choice)
		if choice then
			for i, c in ipairs(choices) do
				if c == choice then
					marks[i] = filepath
					break
				end
			end
			update_display()
		end
	end)
end

function M.jump_to(idx)
	if idx < 1 or idx > #marks then
		vim.notify(string.format("Quickmark: No file at slot %d", idx), vim.log.levels.WARN)
		return
	end
	vim.cmd("edit " .. marks[idx])
end

function M.clear_marks()
	marks = {}
	update_display()
end

function M.remove_mark(idx)
	if idx < 1 or idx > #marks then
		return
	end
	table.remove(marks, idx)
	update_display()
end

function M.suspend(reason)
	if reason ~= "opencode" then
		return
	end

	display_hidden_for_opencode = true
	close_display()
end

function M.resume(reason)
	if reason ~= "opencode" then
		return
	end

	display_hidden_for_opencode = false
	if not display_hidden_for_qf then
		update_display()
	end
end

function M.swap_marks()
	if #marks < 2 then
		vim.notify("Quickmark: Need at least 2 marks to swap", vim.log.levels.WARN)
		return
	end

	close_display()

	local lines = {}
	for i, filepath in ipairs(marks) do
		table.insert(lines, string.format("%d: %s", i, get_formatted_path(filepath)))
	end

	local max_width = 0
	for _, line in ipairs(lines) do
		max_width = math.max(max_width, vim.fn.strdisplaywidth(line))
	end

	local content_width = max_width + 4
	local content_height = #lines
	local editor_width, editor_height = get_editor_dimensions()
	local row = math.max(0, editor_height - content_height - 6)
	local col = math.max(0, editor_width - content_width - 2)

	display_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(display_buf, 0, -1, false, lines)

	display_win = vim.api.nvim_open_win(display_buf, true, {
		relative = "editor",
		width = content_width,
		height = content_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		zindex = 50,
	})

	vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = display_win })
	vim.api.nvim_set_option_value("cursorline", true, { win = display_win })
	vim.api.nvim_set_option_value("number", false, { win = display_win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = display_win })
	vim.api.nvim_set_option_value("signcolumn", "no", { win = display_win })
	vim.api.nvim_set_option_value("foldcolumn", "0", { win = display_win })
	vim.api.nvim_set_option_value("spell", false, { win = display_win })
	vim.api.nvim_set_option_value("wrap", false, { win = display_win })
	vim.api.nvim_set_option_value("list", false, { win = display_win })

	local state = { first_idx = nil }

	local function select_register(idx)
		if not state.first_idx then
			state.first_idx = idx
			vim.api.nvim_buf_add_highlight(display_buf, -1, "Visual", idx - 1, 0, -1)
		else
			local first, second = state.first_idx, idx
			if first ~= second then
				marks[first], marks[second] = marks[second], marks[first]
				vim.notify(string.format("Quickmark: Swapped registers %d and %d", first, second), vim.log.levels.INFO)
			end
			local new_lines = {}
			for j, filepath in ipairs(marks) do
				table.insert(new_lines, string.format("%d: %s", j, get_formatted_path(filepath)))
			end
			vim.api.nvim_buf_set_lines(display_buf, 0, -1, false, new_lines)
			vim.defer_fn(update_display, 0)
		end
	end

	for i = 1, #marks do
		vim.api.nvim_buf_set_keymap(display_buf, "n", tostring(i), "", {
			callback = function()
				select_register(i)
			end,
			desc = string.format("Quickmark: Select register %d", i),
		})
	end

	vim.api.nvim_buf_set_keymap(display_buf, "n", "<CR>", "", {
		callback = function()
			local cur_line = vim.api.nvim_win_get_cursor(display_win)[1]
			select_register(cur_line)
		end,
		desc = "Quickmark: Select register at cursor",
	})

	vim.api.nvim_buf_set_keymap(display_buf, "n", "<Esc>", "", {
		callback = function()
			close_display()
		end,
		desc = "Quickmark: Cancel swap",
	})
end

function M.replace_mark()
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		vim.notify("Quickmark: No file path to mark", vim.log.levels.WARN)
		return
	end

	if #marks == 0 then
		vim.notify("Quickmark: No marks to replace", vim.log.levels.WARN)
		return
	end

	local choices = {}
	for i, mark in ipairs(marks) do
		table.insert(choices, string.format("%d: %s", i, get_formatted_path(mark)))
	end

	vim.ui.select(choices, {
		prompt = "Quickmark: Which register to replace?",
	}, function(choice)
		if not choice then
			return
		end

		for i, c in ipairs(choices) do
			if c == choice then
				marks[i] = filepath
				break
			end
		end
		update_display()
	end)
end

function M.setup(opts)
	opts = opts or {}

	local augroup = vim.api.nvim_create_augroup("Quickmark", { clear = true })
	vim.api.nvim_create_autocmd("VimResized", {
		group = augroup,
		callback = function()
			if not display_hidden_for_qf and not display_hidden_for_opencode then
				update_display()
			end
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = "qf",
		callback = function()
			if display_win and vim.api.nvim_win_is_valid(display_win) then
				display_hidden_for_qf = true
				close_display()
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		callback = function()
			if display_hidden_for_qf and not display_hidden_for_opencode and #marks > 0 then
				local qf_open = false
				for _, win_id in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win_id)
					if vim.bo[buf].filetype == "qf" then
						qf_open = true
						break
					end
				end
				if not qf_open then
					display_hidden_for_qf = false
					update_display()
				end
			end
		end,
	})

	vim.keymap.set("n", opts.mark_keymap or "<M-m>", M.mark_file, { desc = "Quickmark: Mark current file" })
	vim.keymap.set("n", opts.swap_keymap or "<M-s>", M.swap_marks, { desc = "Quickmark: Swap two registers" })
	vim.keymap.set(
		"n",
		opts.replace_keymap or "<M-R>",
		M.replace_mark,
		{ desc = "Quickmark: Replace a register with current file" }
	)
	for i = 1, MAX_MARKS do
		vim.keymap.set("n", string.format("<M-%d>", i), function()
			M.jump_to(i)
		end, { desc = string.format("Quickmark: Jump to mark %d", i) })
	end

	vim.api.nvim_create_user_command("QuickmarkAdd", M.mark_file, {})
	vim.api.nvim_create_user_command("QuickmarkSwap", M.swap_marks, {})
	vim.api.nvim_create_user_command("QuickmarkReplace", M.replace_mark, {})
	vim.api.nvim_create_user_command("QuickmarkClear", M.clear_marks, {})
	vim.api.nvim_create_user_command("QuickmarkRemove", function(args)
		M.remove_mark(tonumber(args.args))
	end, { nargs = 1 })
end

return M
