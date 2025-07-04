local M = {}

local config = require("ziglings.config")
local exercises = require("ziglings.exercises")
local build = require("ziglings.build")

M.setup = function(opts)
  config.setup(opts)
  build.setup_autocmds()
end

-- Public API
M.next_exercise = exercises.next_exercise
M.prev_exercise = exercises.prev_exercise
M.current_exercise = exercises.current_exercise
M.goto_exercise = exercises.goto_exercise
M.list_exercises = exercises.list_exercises
M.build = build.run_build
M.toggle_auto_build = build.toggle_auto_build

return M
