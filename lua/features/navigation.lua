local M = {}
local explorer = require("features.explorer")

local function trimUrl(url)
  local trimmed = url
  while trimmed:match("[%)%]%}>,;%.]$") do
    trimmed = trimmed:sub(1, -2)
  end
  return trimmed
end

local function urlAtCursor()
  local line = vim.api.nvim_get_current_line()
  local cursorColumn = vim.api.nvim_win_get_cursor(0)[2] + 1

  for labelStart, label, urlStart, url in line:gmatch("%[()([^%]]+)%]%(()(https?://[^%)%s]+)%)") do
    local labelEnd = labelStart + #label - 1
    local urlEnd = urlStart + #url - 1
    if (cursorColumn >= labelStart and cursorColumn <= labelEnd) or (cursorColumn >= urlStart and cursorColumn <= urlEnd) then
      return trimUrl(url)
    end
  end

  for urlStart, url in line:gmatch("()(https?://%S+)") do
    local trimmed = trimUrl(url)
    local urlEnd = urlStart + #trimmed - 1
    if cursorColumn >= urlStart and cursorColumn <= urlEnd then
      return trimmed
    end
  end

  return nil
end

local function hasDefinitionProvider()
  return #vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    method = "textDocument/definition",
  }) > 0
end

local function leave_insert_or_terminal_mode()
  local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
  if mode == "i" then
    vim.cmd("stopinsert")
    return
  end

  if mode == "t" then
    vim.api.nvim_feedkeys(vim.keycode("<C-\\><C-n>"), "n", false)
  end
end

function M.find_project_files()
  LazyVim.pick("files", { cwd = explorer.root(), root = false })()
end

function M.find_project_text()
  leave_insert_or_terminal_mode()
  LazyVim.pick("live_grep", { cwd = explorer.root(), root = false })()
end

function M.open_command_palette()
  leave_insert_or_terminal_mode()
  LazyVim.pick("commands")()
end

function M.open_link_or_definition()
  local url = urlAtCursor()
  if url then
    local _, err = vim.ui.open(url)
    if err then
      vim.notify("Failed to open URL: " .. err, vim.log.levels.ERROR)
    end
    return
  end

  if hasDefinitionProvider() then
    vim.lsp.buf.definition()
    return
  end

  vim.cmd.normal({ "gd", bang = true })
end

function M.focus_left_navigation()
  leave_insert_or_terminal_mode()

  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker then
    local explorer_picker = snacks.picker.get({ source = "explorer" })[1]
    if explorer_picker and not explorer_picker.closed then
      explorer_picker:focus()
      return
    end

    snacks.explorer({ cwd = explorer.root() })
    return
  end

  vim.cmd("wincmd h")
end

function M.focus_window(direction)
  if direction == "h" then
    M.focus_left_navigation()
    return
  end

  if direction ~= "j" and direction ~= "k" and direction ~= "l" then
    return
  end

  leave_insert_or_terminal_mode()
  vim.cmd("wincmd " .. direction)
end

return M
