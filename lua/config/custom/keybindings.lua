-- * global config
local map = vim.api.nvim_set_keymap
-- 复用 opt 参数
local opt = {noremap = true, silent = true }

-- * 上下快速移动，左右快速移动在 keymaps.lua 中~
map("n", "J", "5j", opt)
map("n", "K", "5k", opt)
map("x", "J", "5j", opt)
map("x", "K", "5k", opt)
