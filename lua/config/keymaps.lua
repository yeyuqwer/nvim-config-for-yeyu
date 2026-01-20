-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- * 覆盖 BufferLine 插件快捷键
vim.keymap.set("n", "H", "^", { desc = "line start" })
vim.keymap.set("n", "L", "g_", { desc = "line end" })
vim.keymap.set("x", "H", "^", { desc = "line start" })
vim.keymap.set("x", "L", "g_", { desc = "line end" })

-- * 保留原生 mac 的上下左右移动组合键
vim.keymap.set("i", "<C-f>", "<Right>", { noremap = true, desc = "forward char" })
vim.keymap.set("i", "<C-b>", "<Left>",  { noremap = true, desc = "backward char" })

vim.keymap.set("i", "<C-p>", "<Up>",    { noremap = true, desc = "previous line" })
vim.keymap.set("i", "<C-n>", "<Down>",  { noremap = true, desc = "next line" })

-- Command-line mode (:/ ?)
vim.keymap.set("c", "<C-f>", "<Right>", { noremap = true })
vim.keymap.set("c", "<C-b>", "<Left>",  { noremap = true })

vim.keymap.set("c", "<C-p>", "<Up>",    { noremap = true })
vim.keymap.set("c", "<C-n>", "<Down>",  { noremap = true })