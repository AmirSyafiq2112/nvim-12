local M = {}

-- Parse unified diff hunk headers like "@@ -10,4 +12,6 @@"
-- Returns list of { line = N, type = "add"|"delete"|"change" }
local function parse_hunks(diff_output)
	local hunks = {}
	local new_line = 0

	for _, raw in ipairs(diff_output) do
		local start = raw:match("^%+%+%+ (.+)")
		if start then
			-- reset on new file section (multi-file diffs)
		end

		-- hunk header: @@ -old_start,old_count +new_start,new_count @@
		local ns, nc = raw:match("^@@ %-[%d,]+ %+(%d+),?(%d*) @@")
		if ns then
			new_line = tonumber(ns)
		elseif raw:match("^%+") and not raw:match("^%+%+%+") then
			table.insert(hunks, { line = new_line, type = "add" })
			new_line = new_line + 1
		elseif raw:match("^%-") and not raw:match("^%-%-%- ") then
			-- deletion: mark the line before (where it was)
			table.insert(hunks, { line = math.max(new_line, 1), type = "delete" })
			-- don't advance new_line; deleted lines don't exist in new file
		elseif raw:match("^ ") then
			new_line = new_line + 1
		end
	end

	return hunks
end

local function is_new_file(filepath, cb)
	local status = {}
	vim.fn.jobstart({ "git", "status", "--porcelain", "--", filepath }, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			for _, line in ipairs(data) do
				if line ~= "" then
					table.insert(status, line)
				end
			end
		end,
		on_exit = function()
			if #status == 0 then
				cb(false)
				return
			end
			local code = status[1]:sub(1, 2)
			-- "??" = untracked, "A " = staged new file, "AM" = staged+modified new file
			local new = code == "??" or code:sub(1, 1) == "A"
			cb(new)
		end,
	})
end

-- Build fake hunks marking every line as "add"
local function all_lines_added(bufnr)
	local count = vim.api.nvim_buf_line_count(bufnr)
	local hunks = {}
	for i = 1, count do
		table.insert(hunks, { line = i, type = "add" })
	end
	return hunks
end

-- Run `git diff HEAD` for the given file, call cb(hunks) when done
function M.get_hunks(filepath, bufnr, cb)
	is_new_file(filepath, function(new)
		if new then
			cb(all_lines_added(bufnr))
			return
		end

		local stdout = {}
		local job_id = vim.fn.jobstart({ "git", "diff", "HEAD", "--", filepath }, {
			stdout_buffered = true,
			on_stdout = function(_, data)
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(stdout, line)
					end
				end
			end,
			on_exit = function(_, code)
				if code == 0 or code == 1 then -- 1 = has diffs, still valid
					cb(parse_hunks(stdout))
				else
					cb({})
				end
			end,
		})

		if job_id <= 0 then
			cb({}) -- git not found or not in a repo
		end
	end)
end

return M
