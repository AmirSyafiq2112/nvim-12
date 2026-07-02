---@class opencode.events.permissions.edits.Opts
---@field enabled? boolean Diff proposed edits for acceptance or rejection.

local M = {}

---@type integer?
local current_edit_request_id = nil

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

		current_edit_request_id = event.properties.id
		require("opencode_custom.multifile_edit_review").open({
			diff = diff,
			filepaths = filepaths,
			permit = permit,
		})
	elseif event.type == "permission.replied" and current_edit_request_id == event.properties.requestID then
		-- Entire edit was accepted or rejected, either in the plugin or TUI; close the review.
		current_edit_request_id = nil
		require("opencode_custom.multifile_edit_review").close()
	end
end

return M
