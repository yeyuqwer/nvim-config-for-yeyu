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

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "Explorer" })
end

if M.startup_root then
  local cwd = vim.fs.normalize(((vim.uv or vim.loop).cwd() or ""))
  if cwd ~= M.startup_root then
    vim.schedule(function()
      pcall(vim.api.nvim_set_current_dir, M.startup_root)
    end)
  end
end

function M.root()
  return M.startup_root or LazyVim.root({ buf = 0 })
end

local function focused_explorer_picker()
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    return nil
  end

  local picker = snacks.picker.get({ source = "explorer" })[1]
  if not picker or picker.closed or not picker:is_focused() then
    return nil
  end
  local win_name = picker:current_win()
  if win_name ~= "list" then
    return nil
  end

  return picker
end

local function focused_explorer_dir()
  local picker = focused_explorer_picker()
  if not picker then
    return nil
  end

  local ok_dir, dir = pcall(function()
    return picker:dir()
  end)
  if not ok_dir or not dir or dir == "" then
    return nil
  end

  return vim.fs.normalize(dir)
end

local function default_create_dir()
  return focused_explorer_dir() or vim.fs.normalize(M.root() or vim.fn.getcwd())
end

local function delete_path(path)
  local ok_actions, actions = pcall(require, "snacks.explorer.actions")
  if ok_actions and actions.trash then
    return actions.trash(path)
  end

  local ok, ret = pcall(vim.fn.delete, path, "rf")
  if ok and ret == 0 then
    return true
  end
  return false, type(ret) == "string" and ret or "Unknown error"
end

local function resolve_target(input, base_dir)
  local text = vim.trim(input or "")
  if text == "" then
    return nil
  end

  if text:sub(1, 1) == "/" then
    return vim.fs.normalize(text)
  end
  if text:sub(1, 1) == "~" then
    return vim.fs.normalize(vim.fn.expand(text))
  end

  return vim.fs.normalize(vim.fs.joinpath(base_dir, text))
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

function M.create_file()
  local base_dir = default_create_dir()
  vim.ui.input({ prompt = "New file (" .. base_dir .. "): " }, function(input)
    local path = resolve_target(input, base_dir)
    if not path then
      return
    end

    if vim.fn.isdirectory(path) == 1 then
      notify("Cannot create file, path is a directory: " .. path, vim.log.levels.ERROR)
      return
    end

    local parent = vim.fs.dirname(path)
    if vim.fn.isdirectory(parent) == 0 then
      local ok, err = pcall(vim.fn.mkdir, parent, "p")
      if not ok then
        notify("Failed to create parent directory: " .. tostring(err), vim.log.levels.ERROR)
        return
      end
    end

    local file, err = io.open(path, "a")
    if not file then
      notify("Failed to create file: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    file:close()

    vim.cmd.edit(vim.fn.fnameescape(path))
  end)
end

function M.create_folder()
  local base_dir = default_create_dir()
  vim.ui.input({ prompt = "New folder (" .. base_dir .. "): " }, function(input)
    local path = resolve_target(input, base_dir)
    if not path then
      return
    end

    if vim.fn.filereadable(path) == 1 then
      notify("Cannot create folder, path is a file: " .. path, vim.log.levels.ERROR)
      return
    end

    local ok, result = pcall(vim.fn.mkdir, path, "p")
    if not ok or result == 0 then
      notify("Failed to create folder: " .. path, vim.log.levels.ERROR)
      return
    end

    notify("Created folder: " .. path)
  end)
end

function M.delete_current()
  local picker = focused_explorer_picker()
  if picker then
    local item = picker:current()
    local path = item and item.file or nil
    if not path or path == "" then
      notify("No file/folder under explorer cursor", vim.log.levels.WARN)
      return
    end
    path = vim.fs.normalize(path)

    local ok, err = delete_path(path)
    if not ok then
      notify("Failed to delete `" .. path .. "`:\n" .. tostring(err), vim.log.levels.ERROR)
      return
    end

    local ok_snacks, snacks = pcall(require, "snacks")
    if ok_snacks and snacks.bufdelete then
      snacks.bufdelete({ file = path, force = true })
    end

    local ok_tree, tree = pcall(require, "snacks.explorer.tree")
    if ok_tree then
      tree:refresh(vim.fs.dirname(path))
    end

    local ok_actions, actions = pcall(require, "snacks.explorer.actions")
    if ok_actions and actions.update then
      actions.update(picker, { refresh = true })
    end

    notify("Deleted: " .. path)
    return
  end

  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    notify("No file under cursor to delete", vim.log.levels.WARN)
    return
  end
  path = vim.fs.normalize(path)

  if vim.fn.filereadable(path) == 0 and vim.fn.isdirectory(path) == 0 then
    notify("Path does not exist: " .. path, vim.log.levels.WARN)
    return
  end

  local ok, err = delete_path(path)
  if not ok then
    notify("Failed to delete `" .. path .. "`:\n" .. tostring(err), vim.log.levels.ERROR)
    return
  end

  local ok_snacks, snacks = pcall(require, "snacks")
  if ok_snacks and snacks.bufdelete then
    snacks.bufdelete({ file = path, force = true })
  else
    pcall(vim.cmd, "bdelete!")
  end
  notify("Deleted: " .. path)
end

return M
