local M = {}

local config = require("ziglings.config")

M.get_exercises_path = function()
	return vim.fn.stdpath("data") .. "/ziglings"
end

M.is_downloaded = function()
	local exercises_path = M.get_exercises_path()
	return vim.fn.isdirectory(exercises_path .. "/exercises") == 1
		and vim.fn.filereadable(exercises_path .. "/build.zig") == 1
end

M.download_exercises = function(callback)
	local exercises_path = M.get_exercises_path()

	-- If directory exists but is incomplete, remove it first
	if vim.fn.isdirectory(exercises_path) == 1 and not M.is_downloaded() then
		vim.fn.delete(exercises_path, "rf")
	end

	-- Create directory if it doesn't exist
	vim.fn.mkdir(exercises_path, "p")

	local notify = function(msg, level)
		if package.loaded["snacks"] then
			require("snacks").notify(msg, {
				title = "Ziglings Download",
				level = level or vim.log.levels.INFO,
			})
		else
			vim.notify("Ziglings: " .. msg, level or vim.log.levels.INFO)
		end
	end

	notify("Downloading Ziglings exercises...")

	-- Download from Codeberg (new official location)
	vim.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://codeberg.org/ziglings/exercises.git",
		exercises_path,
	}, {
		text = true,
	}, function(result)
		vim.schedule(function()
			if result.code == 0 then
				notify("✅ Ziglings exercises downloaded successfully!")
				if callback then
					callback(true)
				end
			else
				local error_msg = result.stderr or "Download failed"
				notify("❌ Failed to download exercises: " .. error_msg, vim.log.levels.ERROR)
				if callback then
					callback(false)
				end
			end
		end)
	end)
end

M.ensure_downloaded = function(callback)
	if M.is_downloaded() then
		if callback then
			callback(true)
		end
		return
	end

	M.download_exercises(callback)
end

return M
