local M = {}

vim.api.nvim_set_hl(0, "CargoStderr", { fg = "#f38ba8" }) -- red-ish
vim.api.nvim_set_hl(0, "CargoStdout", { fg = "#7cf536" }) -- green
vim.api.nvim_set_hl(0, "CargoInfo", { fg = "#89b4fa" }) -- blue (optional)

local ns = vim.api.nvim_create_namespace("cargo_runner")

local function create_buffer()
	local buf = vim.api.nvim_create_buf(false, true)

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].buflisted = false
	vim.bo[buf].filetype = "log"

	return buf
end

local function create_window(buf)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)

	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	})

	-- keymaps (buffer-local)
	local opts = { buffer = buf, nowait = true }
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(win, true)
	end, opts)
	vim.keymap.set("n", "<Esc>", function()
		vim.api.nvim_win_close(win, true)
	end, opts)

	return win
end

local function append_lines(buf, win, data, default_hl)
	if not data then
		return
	end

	local lines = vim.split(data, "\n", { plain = true })

	if lines[#lines] == "" then
		table.remove(lines, #lines)
	end

	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end

		vim.bo[buf].modifiable = true

		local start = vim.api.nvim_buf_line_count(buf)
		vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)

		for i, line in ipairs(lines) do
			local row = start + i - 1

			-- smarter highlight detection
			local hl = default_hl
			if line:match("^error:") then
				hl = "ErrorMsg"
			elseif line:match("^warning:") then
				hl = "WarningMsg"
			elseif line:match("^note:") then
				hl = "DiagnosticInfo"
			end

			vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
				end_row = row,
				end_col = #line,
				hl_group = hl,
			})
		end

		vim.bo[buf].modifiable = false

		-- auto scroll
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
		end
	end)
end

function M.run_cargo()
	local buf = create_buffer()
	local win = create_window(buf)

	-- initial state
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running cargo..." })
	vim.bo[buf].modifiable = false

	vim.system({ "cargo", "run" }, {
		text = true,

		stdout = function(_, data)
			append_lines(buf, win, data, "CargoStdout")
		end,

		stderr = function(_, data)
			append_lines(buf, win, data, "CargoStderr")
		end,

		-- on exit
		on_exit = function(obj)
			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(buf) then
					return
				end

				vim.bo[buf].modifiable = true
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
					"",
					"[Process exited with code " .. obj.code .. "]",
				})
				vim.bo[buf].modifiable = false
			end)
		end,
	})
end

vim.keymap.set("n", "<leader>rc", M.run_cargo, { desc = "[R]un [C]argo" })

return M
