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

-- macOS: command + p triggers the same action as <leader><space> (Space Space).
map("n", "<D-p>", "<leader><space>", { remap = true, silent = true, desc = "Find files (root dir)" })

-- macOS: command + c copies to system clipboard.
map("n", "<D-c>", '"+yy', { noremap = true, silent = true, desc = "Copy line to system clipboard" })
map("x", "<D-c>", '"+y', { noremap = true, silent = true, desc = "Copy selection to system clipboard" })

-- macOS: command + a selects the whole buffer.
map("n", "<D-a>", "ggVG", { noremap = true, silent = true, desc = "Select all" })
map("x", "<D-a>", "<Esc>ggVG", { noremap = true, silent = true, desc = "Select all" })
map("i", "<D-a>", "<Esc>ggVG", { noremap = true, silent = true, desc = "Select all" })

-- macOS: command + i (lowercase i) manually triggers completion menu.
map("i", "<D-i>", function()
  local ok, cmp = pcall(require, "blink.cmp")
  if ok then
    cmp.show()
    cmp.show_signature()
  else
    vim.api.nvim_feedkeys(vim.keycode("<C-Space>"), "n", false)
  end
end, { silent = true, desc = "Trigger completion menu" })
