local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local sorter = require("telescope.sorters")
local conf = require("telescope.config").values
local themes = require("telescope.themes")

local M = {}

local live_multigrep = function(opts)
	opts = opts or {}
	opts = themes.get_ivy(opts)
	opts.cwd = opts.cwd or vim.uv.cwd()

	local finder = finders.new_async_job({
		command_generator = function(prompt)
			if not prompt or prompt == "" then
				return nil
			end

			local pieces = vim.split(prompt, "  ")
			local args = { "rg" }

			-- local exclude_file = { "!node_modules" }
			--
			-- if exclude_file ~= nil then
			--     vim.list_extend(args, { "-g" })
			--     vim.list_extend(args, exclude_file)
			-- end

			if pieces[1] then
				table.insert(args, "-e")
				table.insert(args, pieces[1])
			end

			if pieces[2] then
				table.insert(args, "-g")
				table.insert(args, pieces[2])
			end

			return vim.iter({
				args,
				{ "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
			})
				:flatten()
				:totable()
		end,
		entry_maker = make_entry.gen_from_vimgrep(opts),
		cwd = opts.cwd,
	})

	pickers
		.new(opts, {
			debounce = 100,
			prompt_title = "Multi Grep",
			finder = finder,
			previewer = conf.grep_previewer(opts),
			sorter = sorter.empty(),
			defaults = {
				file_ignore_patterns = {
					"node_modules",
				},
			},
		})
		:find()
end

M.setup = function()
	vim.keymap.set("n", "<leader>fg", live_multigrep)
end

return M
