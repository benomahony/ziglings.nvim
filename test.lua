-- Simple test to verify the plugin loads correctly
-- Run with: nvim --headless -c "lua dofile('test.lua')"

local ok, ziglings = pcall(require, "ziglings")

if not ok then
  print("❌ Failed to load ziglings plugin")
  os.exit(1)
end

print("✅ Plugin loaded successfully")

-- Test config
local config = require("ziglings.config")
config.setup({
  ziglings_path = "/tmp/test",
  auto_build = false,
})

print("✅ Config setup successful")
print("✅ All tests passed!")
