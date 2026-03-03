local map = vim.keymap.set
local explorer = require("features.explorer")
local navigation = require("features.navigation")
local lsp_actions = require("features.lsp_actions")
local completion = require("features.completion")
local tabs = require("features.tabs")
local terminal = require("features.terminal")

-- Fast movement.
map({ "n", "x" }, "J", "5j", { noremap = true, silent = true })
map({ "n", "x" }, "K", "5k", { noremap = true, silent = true })

-- macOS: command + s saves current buffer.
map("n", "<D-s>", "<cmd>w<CR>", { noremap = true, silent = true, desc = "Save file" })
map("i", "<D-s>", "<C-o>:w<CR>", { noremap = true, silent = true, desc = "Save file" })
map("x", "<D-s>", "<Esc><cmd>w<CR>", { noremap = true, silent = true, desc = "Save file" })

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
map("n", "<D-b>", explorer.toggle, { desc = "Explorer (startup project dir)" })
map({ "n", "i", "t" }, "<D-n>", explorer.create_file, { silent = true, desc = "Create file" })
map({ "n", "i", "t" }, "<D-C-n>", explorer.create_folder, { silent = true, desc = "Create folder" })
map({ "n", "i", "t" }, "<D-0>", navigation.focus_left_navigation, { silent = true, desc = "Focus left navigation pane" })
map({ "n", "i", "t" }, "<D-E>", navigation.focus_left_navigation, { silent = true, desc = "Focus left navigation pane" })
map({ "n", "i", "t" }, "<D-w>", tabs.close_tab_or_all, { silent = true, desc = "Close tab" })
map({ "n", "i", "t" }, "<C-Tab>", tabs.next_tab_cycle, { silent = true, desc = "Next tab (cycle)" })
map({ "n", "i", "t" }, "<C-S-n>", terminal.toggle_project_terminal, { silent = true, desc = "Toggle terminal (project dir)" })

-- Always search files in current startup/project root, even before opening any file.
map("n", "<leader><space>", navigation.find_project_files, { silent = true, desc = "Find files (project dir)" })

-- macOS: command + p searches files in current startup/project root.
map("n", "<D-p>", navigation.find_project_files, { silent = true, desc = "Find files (project dir)" })

-- macOS: command + c copies to system clipboard.
map("n", "<D-c>", '"+yy', { noremap = true, silent = true, desc = "Copy line to system clipboard" })
map("x", "<D-c>", '"+y', { noremap = true, silent = true, desc = "Copy selection to system clipboard" })

-- macOS: command + a selects the whole buffer.
map("n", "<D-a>", "ggVG", { noremap = true, silent = true, desc = "Select all" })
map("x", "<D-a>", "<Esc>ggVG", { noremap = true, silent = true, desc = "Select all" })
map("i", "<D-a>", "<Esc>ggVG", { noremap = true, silent = true, desc = "Select all" })

-- macOS: command + i (lowercase i) manually triggers completion menu.
map("i", "<D-i>", completion.trigger_completion_menu, { silent = true, desc = "Trigger completion menu" })

-- macOS: command + control + i removes unused imports via LSP code action.
map({ "n", "i" }, "<D-C-i>", lsp_actions.remove_unused_imports, { silent = true, desc = "Remove unused imports" })
