local M = {}

local config = require("ziglings.config")
local download = require("ziglings.download")

M.get_progress = function()
  local progress_file = download.get_exercises_path() .. "/.progress.txt"
  if vim.fn.filereadable(progress_file) == 1 then
    local content = vim.fn.readfile(progress_file)
    return tonumber(content[1]) or 1
  end
  return 1
end

M.get_exercise_files = function()
  local exercises_dir = download.get_exercises_path() .. "/exercises"
  if vim.fn.isdirectory(exercises_dir) == 0 then
    return {}
  end
  
  local files = vim.fn.glob(exercises_dir .. "/*.zig", 0, 1)
  table.sort(files, function(a, b)
    local num_a = tonumber(a:match("(%d+)"))
    local num_b = tonumber(b:match("(%d+)"))
    return (num_a or 0) < (num_b or 0)
  end)
  
  return files
end

M.current_exercise = function()
  local progress = M.get_progress()
  local files = M.get_exercise_files()
  
  for _, file in ipairs(files) do
    local num = tonumber(file:match("(%d+)"))
    if num and num >= progress then
      return file, num
    end
  end
  
  return nil, nil
end
M.next_exercise = function()
  download.ensure_downloaded(function(success)
    if not success then return end
    
    local current_file, current_num = M.current_exercise()
    if not current_file then
      vim.notify("No current exercise found", vim.log.levels.WARN)
      return
    end
    
    local files = M.get_exercise_files()
    local next_file = nil
    
    for _, file in ipairs(files) do
      local num = tonumber(file:match("(%d+)"))
      if num and num > current_num then
        next_file = file
        break
      end
    end
    
    if next_file then
      vim.cmd("edit " .. next_file)
    else
      vim.notify("You're already on the last exercise!", vim.log.levels.INFO)
    end
  end)
end

M.prev_exercise = function()
  download.ensure_downloaded(function(success)
    if not success then return end
    
    local current_file, current_num = M.current_exercise()
    if not current_file then
      vim.notify("No current exercise found", vim.log.levels.WARN)
      return
    end
    
    local files = M.get_exercise_files()
    local prev_file = nil
    
    for i = #files, 1, -1 do
      local file = files[i]
      local num = tonumber(file:match("(%d+)"))
      if num and num < current_num then
        prev_file = file
        break
      end
    end
    
    if prev_file then
      vim.cmd("edit " .. prev_file)
    else
      vim.notify("You're already on the first exercise!", vim.log.levels.INFO)
    end
  end)
end
M.goto_exercise = function(num)
  download.ensure_downloaded(function(success)
    if not success then return end
    
    local files = M.get_exercise_files()
    
    for _, file in ipairs(files) do
      local exercise_num = tonumber(file:match("(%d+)"))
      if exercise_num == num then
        vim.cmd("edit " .. file)
        return
      end
    end
    
    vim.notify("Exercise " .. num .. " not found", vim.log.levels.WARN)
  end)
end

M.list_exercises = function()
  download.ensure_downloaded(function(success)
    if not success then return end
    
    local files = M.get_exercise_files()
    local current_file, current_num = M.current_exercise()
    
    local lines = { "Ziglings Exercises:" }
    
    for _, file in ipairs(files) do
      local num = tonumber(file:match("(%d+)"))
      local name = vim.fn.fnamemodify(file, ":t:r")
      local status = ""
      
      if current_num and num < current_num then
        status = " ✅"
      elseif num == current_num then
        status = " 🔵 (current)"
      end
      
      table.insert(lines, string.format("%3d: %s%s", num, name, status))
    end
    
    vim.cmd("new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.modifiable = false
  end)
end

M.open_current_exercise = function()
  download.ensure_downloaded(function(success)
    if not success then return end
    
    local file, num = M.current_exercise()
    if file then
      vim.cmd("edit " .. file)
    else
      vim.notify("No current exercise found", vim.log.levels.WARN)
    end
  end)
end

return M
