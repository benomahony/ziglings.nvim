-- Example configuration for your init.lua or plugin config

-- Minimal setup (auto-initializes):
{
  dir = "/Users/benomahony/Code/open_source/ziglings.nvim",
  name = "ziglings.nvim",
  ft = "zig",
}

-- Or with custom configuration:
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

-- Or if not using a plugin manager, the plugin auto-initializes:
-- vim.opt.rtp:append("/Users/benomahony/Code/open_source/ziglings.nvim")
