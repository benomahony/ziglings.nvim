local M = {}

local config = require("ziglings.config")

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

M.run_build = function()
  local cwd = config.options.ziglings_path
  local build_file = cwd .. "/build.zig"
  
  if vim.fn.filereadable(build_file) == 0 then
    notify("No build.zig found in " .. cwd, vim.log.levels.WARN)
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
        else
          notify("✅ Build successful", vim.log.levels.INFO)
        end
      else
        local error_output = result.stderr or result.stdout or "Build failed"
        notify(error_output, vim.log.levels.ERROR, config.options.notifications.error_timeout)
      end
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
        vim.defer_fn(M.run_build, 50)
      end
    end,
    desc = "Auto-build ziglings exercises on save",
  })
  
  -- Setup keymaps
  local keymaps = config.options.keymaps
  local exercises = require("ziglings.exercises")
  
  vim.keymap.set("n", keymaps.next_exercise, exercises.next_exercise, { desc = "Next ziglings exercise" })
  vim.keymap.set("n", keymaps.prev_exercise, exercises.prev_exercise, { desc = "Previous ziglings exercise" })
  vim.keymap.set("n", keymaps.current_exercise, exercises.current_exercise, { desc = "Current ziglings exercise" })
  vim.keymap.set("n", keymaps.build, M.run_build, { desc = "Build ziglings" })
  vim.keymap.set("n", keymaps.toggle_auto_build, M.toggle_auto_build, { desc = "Toggle auto-build" })
  
  -- Commands
  vim.api.nvim_create_user_command("ZiglingsNext", exercises.next_exercise, { desc = "Go to next exercise" })
  vim.api.nvim_create_user_command("ZiglingsPrev", exercises.prev_exercise, { desc = "Go to previous exercise" })
  vim.api.nvim_create_user_command("ZiglingsCurrent", function()
    local file, num = exercises.current_exercise()
    if file then
      vim.cmd("edit " .. file)
    end
  end, { desc = "Go to current exercise" })
  vim.api.nvim_create_user_command("ZiglingsGoto", function(opts)
    local num = tonumber(opts.args)
    if num then
      exercises.goto_exercise(num)
    else
      vim.notify("Please provide an exercise number", vim.log.levels.WARN)
    end
  end, { desc = "Go to specific exercise", nargs = 1 })
  vim.api.nvim_create_user_command("ZiglingsList", exercises.list_exercises, { desc = "List all exercises" })
  vim.api.nvim_create_user_command("ZiglingsBuild", M.run_build, { desc = "Build current exercise" })
  vim.api.nvim_create_user_command("ZiglingsToggle", M.toggle_auto_build, { desc = "Toggle auto-build" })
end

return M
