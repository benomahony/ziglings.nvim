local M = {}

M.defaults = {
	ziglings_path = nil, -- Auto-detect by default
	auto_build = true,
	notifications = {
		enabled = true,
		timeout = 5000,
		error_timeout = 10000,
	},
	keymaps = {
		next_exercise = "<leader>zn",
		prev_exercise = "<leader>zp",
		current_exercise = "<leader>zc",
		build = "<leader>zb",
		toggle_auto_build = "<leader>zt",
	},
}

M.options = {}

M.setup = function(opts)
	M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})

	-- Auto-detect ziglings path if not provided
	if not M.options.ziglings_path then
		M.options.ziglings_path = M.find_ziglings_root()
	end
end

M.find_ziglings_root = function()
	-- First check if we're already in a ziglings project
	local current_file_dir = vim.fn.expand("%:p:h")
	if current_file_dir ~= "" then
		local dir = current_file_dir
		for _ = 1, 10 do
			local build_file = dir .. "/build.zig"
			if vim.fn.filereadable(build_file) == 1 then
				local content = table.concat(vim.fn.readfile(build_file), "\n")
				if content:match("ziglings") or content:match("exercises") then
					return dir
				end
			end
			local parent = vim.fn.fnamemodify(dir, ":h")
			if parent == dir then break end
			dir = parent
		end
	end
	
	-- Search common locations
	local common_paths = {
		vim.fn.expand("~/ziglings"),
		vim.fn.expand("~/Code/ziglings"),
		vim.fn.expand("~/Code/learning/ziglings"),
		vim.fn.expand("~/projects/ziglings"),
		vim.fn.expand("~/dev/ziglings"),
	}
	
	for _, path in ipairs(common_paths) do
		local build_file = path .. "/build.zig"
		if vim.fn.filereadable(build_file) == 1 then
			local content = table.concat(vim.fn.readfile(build_file), "\n")
			if content:match("ziglings") or content:match("exercises") then
				return path
			end
		end
	end
	
	-- If we're editing a file that looks like a ziglings exercise, 
	-- assume the parent directory might be ziglings
	local current_file = vim.fn.expand("%:t")
	if current_file:match("^%d+_.*%.zig$") then
		local exercises_dir = vim.fn.expand("%:p:h")
		if exercises_dir:match("/exercises$") then
			local ziglings_root = vim.fn.fnamemodify(exercises_dir, ":h")
			local build_file = ziglings_root .. "/build.zig"
			if vim.fn.filereadable(build_file) == 1 then
				return ziglings_root
			end
		end
	end
	
	-- Last resort: current working directory
	return vim.fn.getcwd()
end

return M
