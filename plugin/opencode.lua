---@type opencode.Opts
vim.g.opencode_opts = {
	-- Your configuration, if any; goto definition on the type for details
}

-- OpenCode Neovim integration settings live here.

vim.o.autoread = true -- Required for `vim.g.opencode_opts.events.reload`

-- Source event handlers from subdirectories (not auto-loaded by Neovim)
vim.cmd("runtime plugin/events/reload.lua")
vim.cmd("runtime plugin/events/status.lua")
vim.cmd("runtime plugin/events/permissions/init.lua")
vim.cmd("runtime plugin/events/permissions/edits.lua")

-- Recommended/example keymaps
vim.keymap.set({ "n", "x" }, "<leader>oa", function()
	require("opencode").ask("@this: ")
end, { desc = "Ask OpenCode…" })
vim.keymap.set({ "n", "x" }, "<leader>os", function()
	require("opencode").select()
end, { desc = "Select OpenCode…" })

vim.keymap.set({ "n", "x" }, "go", function()
	return require("opencode").operator("@this ")
end, { desc = "Append range to OpenCode", expr = true })
vim.keymap.set("n", "goo", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Append line to OpenCode", expr = true })

vim.keymap.set("n", "<S-C-u>", function()
	require("opencode").command("session.half.page.up")
end, { desc = "Scroll OpenCode up" })
vim.keymap.set("n", "<S-C-d>", function()
	require("opencode").command("session.half.page.down")
end, { desc = "Scroll OpenCode down" })

vim.api.nvim_create_user_command("OpencodeEditReviewDemo", function()
	local diff = vim.fn.systemlist({ "git", "diff", "--" })
	if vim.v.shell_error ~= 0 then
		vim.notify(table.concat(diff, "\n"), vim.log.levels.ERROR, { title = "opencode" })
		return
	end

	local filepaths = vim.fn.systemlist({ "git", "diff", "--name-only", "--" })
	if vim.v.shell_error ~= 0 then
		vim.notify(table.concat(filepaths, "\n"), vim.log.levels.ERROR, { title = "opencode" })
		return
	end

	if #diff == 0 or #filepaths == 0 then
		vim.notify("No git diff to preview", vim.log.levels.INFO, { title = "opencode" })
		return
	end

	require("opencode_custom.multifile_edit_review").open({
		diff = table.concat(diff, "\n"),
		filepaths = filepaths,
		permit = function(reply)
			vim.notify("Preview only; no OpenCode permission request was sent: " .. reply, vim.log.levels.INFO, {
				title = "opencode",
			})
		end,
	})
end, { desc = "Preview current git diff in the OpenCode multi-file edit review UI" })

vim.api.nvim_create_user_command("OpencodeEditReviewReopen", function()
	require("opencode_custom.multifile_edit_review").reopen()
end, { desc = "Reopen the pending OpenCode multi-file edit review" })

local function path_overlaps(left, right)
	left = vim.fs.normalize(left)
	right = vim.fs.normalize(right)
	return left == right or vim.startswith(left, right .. "/") or vim.startswith(right, left .. "/")
end

local function connect_latest_opencode_server()
	local Promise = require("opencode.promise")

	require("opencode.server.discovery")
		.locally()
		:next(function(servers)
			local cwd = vim.fn.getcwd()
			local candidates = vim.tbl_filter(function(server)
				return server.cwd and path_overlaps(cwd, server.cwd)
			end, servers)

			if #candidates == 0 then
				return require("opencode.promise").reject("No OpenCode servers found with overlapping CWD")
			end

			if #candidates == 1 then
				return candidates[1]
			end

			return Promise.all(vim.tbl_map(function(server)
				return server
					:get_sessions()
					:catch(function()
						return {}
					end)
					:next(function(sessions)
						local latest_updated = 0
						for _, session in ipairs(sessions) do
							latest_updated = math.max(latest_updated, session.time and session.time.updated or 0)
						end

						return {
							server = server,
							latest_updated = latest_updated,
						}
					end)
			end, candidates)):next(function(ranked_candidates)
				table.sort(ranked_candidates, function(left, right)
					if left.latest_updated == right.latest_updated then
						return left.server.cwd < right.server.cwd
					end
					return left.latest_updated > right.latest_updated
				end)

				local best = ranked_candidates[1]
				local tied_candidates = vim.tbl_filter(function(candidate)
					return candidate.latest_updated == best.latest_updated
				end, ranked_candidates)

				if #tied_candidates == 1 then
					return best.server
				end

				return require("opencode.ui.select_server").select_server(vim.tbl_map(function(candidate)
					return candidate.server
				end, tied_candidates))
			end)
		end)
		:next(function(server)
			return server:connect():next(function()
				vim.notify(
					("Connected to OpenCode: %s"):format(server:display_name()),
					vim.log.levels.INFO,
					{ title = "opencode" }
				)
			end)
		end)
		:catch(function(err)
			vim.notify("Failed to connect to OpenCode: " .. tostring(err), vim.log.levels.ERROR, { title = "opencode" })
		end)
end

vim.api.nvim_create_user_command("OpencodeConnect", function()
	connect_latest_opencode_server()
end, { desc = "Connect Neovim to a local OpenCode server matching the current CWD" })

vim.keymap.set("n", "<leader>oc", function()
	connect_latest_opencode_server()
end, { desc = "[O]pencode [Connect]; OpencodeConnect" })

local opencode_event_debug = false
vim.api.nvim_create_user_command("OpencodeEventDebug", function()
	opencode_event_debug = not opencode_event_debug
	if opencode_event_debug then
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("OpencodeEventDebug", { clear = true }),
			pattern = "OpencodeEvent:*",
			callback = function(args)
				local event = args.data and args.data.event or {}
				local properties = event.properties or {}
				vim.notify(
					vim.inspect({
						type = event.type,
						permission = properties.permission,
						filepath = properties.metadata and properties.metadata.filepath,
					}),
					vim.log.levels.INFO,
					{ title = "opencode event" }
				)
			end,
		})
		vim.notify("OpenCode event debug enabled", vim.log.levels.INFO, { title = "opencode" })
	else
		vim.api.nvim_clear_autocmds({ group = "OpencodeEventDebug" })
		vim.notify("OpenCode event debug disabled", vim.log.levels.INFO, { title = "opencode" })
	end
end, { desc = "Toggle OpenCode event debug notifications" })
