local M = {}

M.defaults = {
  auto_build = true,
  auto_download = true,
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
    download = "<leader>zd",
  },
}

M.options = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
