local map = vim.keymap.set
local explorer = require("features.explorer")

local function find_project_files()
  LazyVim.pick("files", { cwd = explorer.root(), root = false })()
end

local function remove_unused_imports()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    method = "textDocument/codeAction",
  })
  if #clients == 0 then
    return
  end

  local position_encoding = clients[1].offset_encoding or "utf-16"
  local params = vim.lsp.util.make_range_params(0, position_encoding)
  params.context = {
    diagnostics = vim.diagnostic.get(bufnr),
    only = {
      "source.removeUnusedImports",
      "source.removeUnusedImports.ts",
    },
  }

  local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000) or {}
  local actions = {}

  for client_id, response in pairs(responses) do
    for _, action in ipairs(response.result or {}) do
      actions[#actions + 1] = {
        action = action,
        client_id = client_id,
      }
    end
  end

  if #actions == 0 then
    return
  end

  table.sort(actions, function(a, b)
    local a_preferred = a.action.isPreferred == true
    local b_preferred = b.action.isPreferred == true
    if a_preferred ~= b_preferred then
      return a_preferred
    end

    local a_kind = a.action.kind or ""
    local b_kind = b.action.kind or ""
    if a_kind ~= b_kind then
      return a_kind < b_kind
    end

    return (a.action.title or "") < (b.action.title or "")
  end)

  local selected = actions[1]
  local action = selected.action
  local client = vim.lsp.get_client_by_id(selected.client_id)

  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client and client.offset_encoding or "utf-16")
  end

  local command = action.command
  if not command then
    return
  end

  if type(command) == "table" then
    if client and client.supports_method("workspace/executeCommand") then
      client:exec_cmd(command, { bufnr = bufnr })
    else
      vim.lsp.buf.execute_command(command)
    end
    return
  end

  vim.lsp.buf.execute_command({
    command = command,
    arguments = action.arguments,
  })
end

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

-- Always search files in current startup/project root, even before opening any file.
map("n", "<leader><space>", find_project_files, { silent = true, desc = "Find files (project dir)" })

-- macOS: command + p searches files in current startup/project root.
map("n", "<D-p>", find_project_files, { silent = true, desc = "Find files (project dir)" })

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

-- macOS: command + control + i removes unused imports via LSP code action.
map({ "n", "i" }, "<D-C-i>", remove_unused_imports, { silent = true, desc = "Remove unused imports" })
