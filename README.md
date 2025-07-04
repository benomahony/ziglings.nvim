# ziglings.nvim

A Neovim plugin for learning Zig with [Ziglings](https://ziglings.org/) exercises. The plugin automatically downloads and manages all exercises, provides auto-building, exercise navigation, and progress tracking.

## Features

- Auto-downloads Ziglings exercises
- Builds on save
- Exercise navigation
- Progress tracking
- Zero configuration

## Installation

### lazy.nvim

```lua
return {
  "benomahony/ziglings.nvim" 
}
```

### packer.nvim

```lua
use "benomahony/ziglings.nvim"
```

## Configuration

**No configuration required!**

For customization:

```lua
{
  "benomahony/ziglings.nvim",
  opts = {
    keymaps = {
      next_exercise = "<leader>zn",
      prev_exercise = "<leader>zp",
      current_exercise = "<leader>zc",
    },
  },
}
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
- `:ZiglingsDownload` - Manually download/update exercises

### Default Keymaps

- `<leader>zn` - Next exercise
- `<leader>zp` - Previous exercise
- `<leader>zc` - Current exercise
- `<leader>zb` - Build
- `<leader>zt` - Toggle auto-build
- `<leader>zd` - Download exercises

## How it works

The plugin automatically downloads the Ziglings repository to your Neovim data directory (`~/.local/share/nvim/ziglings` on Linux/macOS) **once** when you first use any Ziglings command or open a `.zig` file. Subsequent uses are instant since the exercises are already cached locally.

It tracks your progress through a `.progress.txt` file and provides easy navigation between exercises. When auto-build is enabled (default), saving any `.zig` file will trigger `zig build` and show you the results via notifications.

All exercises are self-contained within the plugin's data directory, so you don't need to manually manage any Ziglings installation.

## Requirements

- Neovim 0.8+
- Zig compiler
- Git (for downloading exercises)
- Optional: [snacks.nvim](https://github.com/folke/snacks.nvim) for enhanced notifications

## Getting Started

1. Install the plugin with your package manager
2. Start learning Zig: `:ZiglingsCurrent` to open the first exercise
3. Edit and save to auto-build
4. Use `:ZiglingsNext` when you complete an exercise

## License

MIT
