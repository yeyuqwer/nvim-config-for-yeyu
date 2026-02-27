local map = vim.keymap.set

-- Fast movement.
map({ "n", "x" }, "J", "5j", { noremap = true, silent = true })
map({ "n", "x" }, "K", "5k", { noremap = true, silent = true })

-- Line start/end.
map("n", "H", "^", { desc = "line start" })
map("n", "L", "g_", { desc = "line end" })
map("x", "H", "^", { desc = "line start" })
map("x", "L", "g_", { desc = "line end" })

-- Keep macOS style Ctrl motions in insert mode.
map("i", "<C-f>", "<Right>", { noremap = true, desc = "forward char" })
map("i", "<C-b>", "<Left>", { noremap = true, desc = "backward char" })
map("i", "<C-p>", "<Up>", { noremap = true, desc = "previous line" })
map("i", "<C-n>", "<Down>", { noremap = true, desc = "next line" })

-- Command-line mode (:/ ?)
map("c", "<C-f>", "<Right>", { noremap = true })
map("c", "<C-b>", "<Left>", { noremap = true })
map("c", "<C-p>", "<Up>", { noremap = true })
map("c", "<C-n>", "<Down>", { noremap = true })

-- macOS: command + b toggles file explorer.
map("n", "<D-b>", require("features.explorer").toggle, { desc = "Explorer (startup project dir)" })
