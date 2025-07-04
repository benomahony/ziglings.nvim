# ziglings.nvim

A Neovim plugin for working with [Ziglings](https://ziglings.org/) exercises. Provides auto-building, exercise navigation, and progress tracking.

## Features

- 🚀 **Auto-build on save**: Automatically runs `zig build` when you save `.zig` files
- 📍 **Exercise navigation**: Jump between exercises with simple commands
- 📊 **Progress tracking**: See which exercises you've completed
- 🔔 **Smart notifications**: Get build results with full error context
- ⚡ **Snacks.nvim integration**: Enhanced notifications if you use snacks.nvim

## Installation

### lazy.nvim

```lua
{
  "benomahony/ziglings.nvim",
  ft = "zig", -- Auto-initializes when opening .zig files
}
```

Or with custom configuration:

```lua
{
  "benomahony/ziglings.nvim",
  config = function()
    require("ziglings").setup({
      -- Custom options here
    })
  end,
  ft = "zig",
}
```

### packer.nvim

```lua
use {
  "benomahony/ziglings.nvim",
  ft = "zig", -- Auto-initializes when opening .zig files
}
```

## Configuration

**No configuration required!** The plugin auto-initializes when opening `.zig` files in a Ziglings project.

For custom configuration:

```lua
require("ziglings").setup({
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
})
```

## Usage

### Commands

- `:ZiglingsNext` - Go to next exercise
- `:ZiglingsPrev` - Go to previous exercise  
- `:ZiglingsCurrent` - Go to current exercise (based on progress)
- `:ZiglingsGoto <num>` - Go to specific exercise number
- `:ZiglingsList` - List all exercises with completion status
- `:ZiglingsBuild` - Manually trigger build
- `:ZiglingsToggle` - Toggle auto-build on/off

### Default Keymaps

- `<leader>zn` - Next exercise
- `<leader>zp` - Previous exercise
- `<leader>zc` - Current exercise
- `<leader>zb` - Build
- `<leader>zt` - Toggle auto-build

## How it works

The plugin automatically detects your Ziglings installation by looking for `build.zig` files that contain "ziglings" or "exercises". It reads the `.progress.txt` file to track your current progress and provides easy navigation between exercises.

When auto-build is enabled (default), saving any `.zig` file will trigger `zig build` and show you the results via notifications.

## Requirements

- Neovim 0.8+
- Zig compiler
- [Ziglings exercises](https://github.com/ratfactor/ziglings)
- Optional: [snacks.nvim](https://github.com/folke/snacks.nvim) for enhanced notifications

## License

MIT
