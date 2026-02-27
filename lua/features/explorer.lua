local M = {}

local function startup_root()
  local args = vim.fn.argv()
  local first = type(args) == "table" and args[1] or nil
  if not first or first == "" then
    return nil
  end

  local abs = vim.fs.normalize(vim.fn.fnamemodify(first, ":p"))
  if vim.fn.isdirectory(abs) == 1 then
    return abs
  end
  if vim.fn.filereadable(abs) == 1 then
    return vim.fs.dirname(abs)
  end
  return nil
end

M.startup_root = startup_root()

function M.root()
  return M.startup_root or LazyVim.root({ buf = 0 })
end

function M.toggle()
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    return
  end

  local explorer = snacks.picker.get({ source = "explorer" })[1]
  if explorer and explorer:is_focused() then
    explorer:close()
    return
  end

  snacks.explorer({ cwd = M.root() })
end

return M
