local M = {}
local explorer = require("features.explorer")

function M.find_project_files()
  LazyVim.pick("files", { cwd = explorer.root(), root = false })()
end

function M.focus_left_navigation()
  local mode = vim.api.nvim_get_mode().mode
  if mode:sub(1, 1) == "i" or mode:sub(1, 1) == "t" then
    vim.cmd("stopinsert")
  end

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

return M
