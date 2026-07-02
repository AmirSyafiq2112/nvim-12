---@class opencode.events.permissions.edits.Opts
---@field enabled? boolean Diff proposed edits for acceptance or rejection.

local M = {}

---@type integer?
local current_edit_request_id = nil
---@type integer?
local diff_tabpage = nil

---@param filepath string
---@return string
local function resolve_filepath(filepath)
	local absolute_filepath = vim.fn.fnamemodify(filepath, ":p")

	-- Opencode sends the absolute path sometimes with the HOME and sometimes without
	-- It has something to do with the path of the opencode server cwd wrt the file/directory
	if vim.fn.filereadable(absolute_filepath) == 1 then
		return absolute_filepath
	elseif vim.env.HOME and vim.env.HOME ~= "" then
		local home_filepath = vim.fs.normalize(vim.fs.joinpath(vim.env.HOME, filepath))
		if vim.fn.filereadable(home_filepath) == 1 then
			return home_filepath
		end
	end

	return filepath
end

---@param filepath string
---@return string[]
local function split_filepaths(filepath)
	local filepaths = {}
	for target in filepath:gmatch("[^,]+") do
		target = vim.trim(target)
		if target ~= "" then
			table.insert(filepaths, target)
		end
	end
	return filepaths
end

---@param event opencode.server.Event
---@param server opencode.server.Server
function M.diff(event, server)
	if event.type == "permission.asked" and event.properties.permission == "edit" then
		local metadata = event.properties.metadata
		if not metadata or not metadata.diff or not metadata.filepath then
			vim.notify("OpenCode edit permission did not include diff metadata", vim.log.levels.WARN, { title = "opencode" })
			return
		end

		local diff = metadata.diff

		local filepath = metadata.filepath
		local filepaths = split_filepaths(filepath)

		---@param reply opencode.server.PermissionReply
		local function permit(reply)
			server:permit(event.properties.id, reply):catch(function(msg)
				vim.notify(msg, vim.log.levels.ERROR, { title = "opencode" })
			end)
		end

		if #filepaths > 1 then
			current_edit_request_id = event.properties.id
			require("opencode_custom.multifile_edit_review").open({
				diff = diff,
				filepaths = filepaths,
				permit = permit,
			})
			return
		end

		filepath = resolve_filepath(filepath)

		if vim.fn.filereadable(filepath) ~= 1 then
			vim.notify("Cannot resolve OpenCode edit target file: " .. filepath, vim.log.levels.ERROR, { title = "opencode" })
			return
		end

		local patch_filepath = vim.fn.tempname() .. ".patch"
		if vim.fn.writefile(vim.split(diff, "\n"), patch_filepath) ~= 0 then
			vim.notify(
				"Failed to write patch file to diff opencode edit request",
				vim.log.levels.ERROR,
				{ title = "opencode" }
			)
			return
		end

		filepath = vim.fn.fnameescape(filepath)

		-- Diffing changes some of the buffer's display options (namely folding) to make it easier to compare side-by-side,
		-- so open the target file in a new tab first.
		vim.cmd("tabnew " .. filepath)
		--  FIX: Errors in diff occur due to opencode's trimDiff function
		vim.cmd("silent vert diffpatch " .. patch_filepath)

		local diff_buff = vim.api.nvim_get_current_buf()
		-- When done, wipe out the buffer to avoid "Buffer with this name already exists" error when successive edit requests come in for the same file.
		-- Also prevents it from lingering in e.g. pickers and `:ls`.
		vim.bo[diff_buff].bufhidden = "wipe"
		diff_tabpage = vim.api.nvim_get_current_tabpage()
		current_edit_request_id = event.properties.id

		-- Override native accept/reject keymaps to reject the edit as a whole first, if it hasn't been already
		vim.keymap.set("n", "dp", function()
			if current_edit_request_id then
				-- Clear so we don't close the tabpage in the "permission.replied" handler
				-- and user can continue accepting/rejecting individual hunks (and then close the tabpage manually)
				current_edit_request_id = nil
				permit("reject")
			end
			return "dp"
		end, { buffer = true, desc = "Accept OpenCode edit hunk", expr = true })
		vim.keymap.set("n", "do", function()
			if current_edit_request_id then
				current_edit_request_id = nil
				permit("reject")
			end
			return "do"
		end, { buffer = true, desc = "Reject OpenCode edit hunk", expr = true })
		-- Accept/reject edit as a whole
		vim.keymap.set("n", "da", function()
			permit("once")
		end, { buffer = true, desc = "Accept OpenCode edit" })
		vim.keymap.set("n", "dr", function()
			permit("reject")
		end, { buffer = true, desc = "Reject OpenCode edit" })
		-- Close diff
		vim.keymap.set("n", "q", function()
			vim.cmd("tabclose")
			current_edit_request_id = nil
			diff_tabpage = nil
		end, { buffer = true, desc = "Close OpenCode edit diff" })
	elseif event.type == "permission.replied" and current_edit_request_id == event.properties.requestID then
		-- Entire edit was accepted or rejected, either in the plugin or TUI; close the diff
		current_edit_request_id = nil
		require("opencode_custom.multifile_edit_review").close()
		if diff_tabpage and vim.api.nvim_tabpage_is_valid(diff_tabpage) then
			vim.api.nvim_set_current_tabpage(diff_tabpage)
			vim.cmd("tabclose")
			diff_tabpage = nil
		end
	end
end

return M
