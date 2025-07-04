-- Auto-initialize ziglings.nvim
if vim.g.loaded_ziglings then
  return
end
vim.g.loaded_ziglings = 1

require("ziglings")
