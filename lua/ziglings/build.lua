local M = {}

local config = require("ziglings.config")
local download = require("ziglings.download")

M.auto_build_enabled = true

local function notify(msg, level, timeout)
	if not config.options.notifications.enabled then
		return
	end

	local actual_timeout = timeout or config.options.notifications.timeout

	if package.loaded["snacks"] then
		require("snacks").notify(msg, {
			title = level == vim.log.levels.ERROR and "❌ Zig Build Failed" or "✅ Zig Build",
			level = level,
			timeout = actual_timeout,
		})
	else
		vim.notify(msg, level)
	end
end

local function advance_progress()
	local exercises = require("ziglings.exercises")
	local current_file, current_num = exercises.current_exercise()

	if current_file and current_num then
		local files = exercises.get_exercise_files()
		local next_num = nil

		for _, file in ipairs(files) do
			local num = tonumber(file:match("(%d+)"))
			if num and num > current_num then
				next_num = num
				break
			end
		end

		if next_num then
			exercises.set_progress(next_num)
			notify(
				string.format("🎉 Exercise %d completed! Advanced to exercise %d", current_num, next_num),
				vim.log.levels.INFO
			)
		else
			notify("🏆 Congratulations! You've completed all Ziglings exercises!", vim.log.levels.INFO)
		end
	end
end

M.run_build = function()
	download.ensure_downloaded(function(success)
		if not success then
			return
		end

		local cwd = download.get_exercises_path()
		local build_file = cwd .. "/build.zig"

		if vim.fn.filereadable(build_file) == 0 then
			notify("No build.zig found", vim.log.levels.WARN)
			return
		end

		vim.system({ "zig", "build" }, {
			cwd = cwd,
			text = true,
		}, function(result)
			vim.schedule(function()
				if result.code == 0 then
					local output = result.stdout or ""
					if output:match("PASSED") then
						notify("✅ Exercise completed!", vim.log.levels.INFO)
						advance_progress()
					else
						notify("✅ Build successful", vim.log.levels.INFO)
					end
				else
					local error_output = result.stderr or result.stdout or "Build failed"
					notify(error_output, vim.log.levels.ERROR, config.options.notifications.error_timeout)
				end
			end)
		end)
	end)
end
M.toggle_auto_build = function()
	M.auto_build_enabled = not M.auto_build_enabled
	local status = M.auto_build_enabled and "enabled" or "disabled"
	notify("Auto-build " .. status, vim.log.levels.INFO)
end

M.setup_autocmds = function()
	local group = vim.api.nvim_create_augroup("ZiglingsAutoBuild", { clear = true })

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		pattern = "*.zig",
		callback = function()
			if M.auto_build_enabled and config.options.auto_build then
				local current_file = vim.fn.expand("%:p")
				local exercises_path = download.get_exercises_path()

				-- Only auto-build if we're in the ziglings exercises directory
				if current_file:find(exercises_path, 1, true) then
					vim.defer_fn(M.run_build, 50)
				end
			end
		end,
		desc = "Auto-build ziglings exercises on save",
	})

	-- Setup keymaps
	local keymaps = config.options.keymaps
	local exercises = require("ziglings.exercises")

	vim.keymap.set("n", keymaps.next_exercise, exercises.next_exercise, { desc = "Next ziglings exercise" })
	vim.keymap.set("n", keymaps.prev_exercise, exercises.prev_exercise, { desc = "Previous ziglings exercise" })
	vim.keymap.set(
		"n",
		keymaps.current_exercise,
		exercises.open_current_exercise,
		{ desc = "Current ziglings exercise" }
	)
	vim.keymap.set("n", keymaps.list_exercises, exercises.list_exercises, { desc = "List ziglings exercises" })
	vim.keymap.set("n", keymaps.show_progress, exercises.show_progress, { desc = "Show ziglings progress" })
	vim.keymap.set("n", keymaps.build, M.run_build, { desc = "Build ziglings" })
	vim.keymap.set("n", keymaps.toggle_auto_build, M.toggle_auto_build, { desc = "Toggle auto-build" })
	vim.keymap.set("n", keymaps.download, download.download_exercises, { desc = "Download ziglings exercises" })

	-- Commands
	vim.api.nvim_create_user_command("ZiglingsNext", exercises.next_exercise, { desc = "Go to next exercise" })
	vim.api.nvim_create_user_command("ZiglingsPrev", exercises.prev_exercise, { desc = "Go to previous exercise" })
	vim.api.nvim_create_user_command(
		"ZiglingsCurrent",
		exercises.open_current_exercise,
		{ desc = "Go to current exercise" }
	)
	vim.api.nvim_create_user_command("ZiglingsGoto", function(opts)
		local num = tonumber(opts.args)
		if num then
			exercises.goto_exercise(num)
		else
			vim.notify("Please provide an exercise number", vim.log.levels.WARN)
		end
	end, { desc = "Go to specific exercise", nargs = 1 })
	vim.api.nvim_create_user_command("ZiglingsList", exercises.list_exercises, { desc = "List all exercises" })
	vim.api.nvim_create_user_command("ZiglingsProgress", exercises.show_progress, { desc = "Show progress" })
	vim.api.nvim_create_user_command("ZiglingsBuild", M.run_build, { desc = "Build current exercise" })
	vim.api.nvim_create_user_command("ZiglingsToggle", M.toggle_auto_build, { desc = "Toggle auto-build" })
	vim.api.nvim_create_user_command("ZiglingsDownload", function()
		download.download_exercises(function(success)
			if success then
				vim.notify("Ziglings exercises downloaded successfully!", vim.log.levels.INFO)
			end
		end)
	end, { desc = "Download ziglings exercises" })
end

return M
