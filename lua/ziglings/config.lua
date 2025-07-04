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
  -- Look for build.zig with ziglings-specific content
  local current_dir = vim.fn.expand("%:p:h")
  local max_depth = 10
  
  for _ = 1, max_depth do
    local build_file = current_dir .. "/build.zig"
    if vim.fn.filereadable(build_file) == 1 then
      local content = table.concat(vim.fn.readfile(build_file), "\n")
      if content:match("ziglings") or content:match("exercises") then
        return current_dir
      end
    end
    
    local parent = vim.fn.fnamemodify(current_dir, ":h")
    if parent == current_dir then break end
    current_dir = parent
  end
  
  -- Fallback to current working directory
  return vim.fn.getcwd()
end

return M
