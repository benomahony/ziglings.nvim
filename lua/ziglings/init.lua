local M = {}

local config = require("ziglings.config")
local exercises = require("ziglings.exercises")
local build = require("ziglings.build")

local initialized = false

local function ensure_initialized()
  if initialized then return end
  
  config.setup()
  build.setup_autocmds()
  initialized = true
end

-- Auto-initialize when any API function is called
M.setup = function(opts)
  config.setup(opts)
  build.setup_autocmds()
  initialized = true
end

-- Public API with auto-initialization
M.next_exercise = function() ensure_initialized(); return exercises.next_exercise() end
M.prev_exercise = function() ensure_initialized(); return exercises.prev_exercise() end
M.current_exercise = function() ensure_initialized(); return exercises.current_exercise() end
M.goto_exercise = function(...) ensure_initialized(); return exercises.goto_exercise(...) end
M.list_exercises = function() ensure_initialized(); return exercises.list_exercises() end
M.build = function() ensure_initialized(); return build.run_build() end
M.toggle_auto_build = function() ensure_initialized(); return build.toggle_auto_build() end

-- Auto-initialize on require if we're in a ziglings project
local function auto_detect_and_init()
  local ziglings_path = config.find_ziglings_root()
  if ziglings_path and vim.fn.filereadable(ziglings_path .. "/build.zig") == 1 then
    local content = table.concat(vim.fn.readfile(ziglings_path .. "/build.zig"), "\n")
    if content:match("ziglings") or content:match("exercises") then
      ensure_initialized()
    end
  end
end

-- Auto-initialize when plugin loads if in ziglings project
vim.defer_fn(auto_detect_and_init, 100)

-- Also auto-initialize when opening .zig files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "zig",
  once = true,
  callback = auto_detect_and_init,
  desc = "Auto-initialize ziglings.nvim for Zig files",
})

return M
