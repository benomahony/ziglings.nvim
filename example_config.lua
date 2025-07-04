-- Example configuration for your init.lua or plugin config

-- If using lazy.nvim:
{
  dir = "/Users/benomahony/Code/open_source/ziglings.nvim",
  name = "ziglings.nvim",
  config = function()
    require("ziglings").setup({
      ziglings_path = "/Users/benomahony/Code/learning/ziglings", -- or let it auto-detect
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
    })
  end,
  ft = "zig",
}

-- Or if not using a plugin manager, add to your init.lua:
-- vim.opt.rtp:append("/Users/benomahony/Code/open_source/ziglings.nvim")
-- require("ziglings").setup()
