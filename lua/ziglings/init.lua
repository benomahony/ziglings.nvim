local M = {}

local config = require("ziglings.config")
local exercises = require("ziglings.exercises")
local build = require("ziglings.build")
local download = require("ziglings.download")

local initialized = false

local function ensure_initialized()
  if initialized then return end
  
  config.setup()
  build.setup_autocmds()
  
  -- Auto-download on first use if enabled
  if config.options.auto_download then
    download.ensure_downloaded()
  end
  
  initialized = true
end

-- Auto-initialize when any API function is called
M.setup = function(opts)
  config.setup(opts)
  build.setup_autocmds()
  
  -- Auto-download on setup if enabled
  if config.options.auto_download then
    download.ensure_downloaded()
  end
  
  initialized = true
end

-- Public API with auto-initialization
M.next_exercise = function() ensure_initialized(); return exercises.next_exercise() end
M.prev_exercise = function() ensure_initialized(); return exercises.prev_exercise() end
M.current_exercise = function() ensure_initialized(); return exercises.open_current_exercise() end
M.goto_exercise = function(...) ensure_initialized(); return exercises.goto_exercise(...) end
M.list_exercises = function() ensure_initialized(); return exercises.list_exercises() end
M.build = function() ensure_initialized(); return build.run_build() end
M.toggle_auto_build = function() ensure_initialized(); return build.toggle_auto_build() end
M.download = function(...) ensure_initialized(); return download.download_exercises(...) end

-- Auto-initialize when plugin loads
local function auto_init()
  ensure_initialized()
end

-- Auto-initialize when plugin loads
vim.defer_fn(auto_init, 100)

-- Also auto-initialize when opening .zig files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zig",
  once = true,
  callback = auto_init,
  desc = "Auto-initialize ziglings.nvim for Zig files",
})

return M
