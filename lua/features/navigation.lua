local M = {}
local explorer = require("features.explorer")

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
