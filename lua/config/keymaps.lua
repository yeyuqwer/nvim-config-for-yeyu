-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- * 覆盖 BufferLine 插件快捷键
vim.keymap.set("n", "H", "^", { desc = "line start" })
vim.keymap.set("n", "L", "g_", { desc = "line end" })
vim.keymap.set("x", "H", "^", { desc = "line start" })
vim.keymap.set("x", "L", "g_", { desc = "line end" })