local M = {}

local close_all_armed = false
local arm_token = 0

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

function M.arm_close_all_tabs()
  arm_token = arm_token + 1
  local token = arm_token
  close_all_armed = true
  vim.defer_fn(function()
    if arm_token == token then
      close_all_armed = false
    end
  end, 2500)
end

function M.close_tab_or_all()
  leave_insert_or_terminal_mode()

  local ok, snacks = pcall(require, "snacks")

  if close_all_armed then
    close_all_armed = false
    if ok and snacks.bufdelete and snacks.bufdelete.all then
      snacks.bufdelete.all()
    else
      pcall(vim.cmd, "bufdo bdelete")
    end
    return
  end

  if ok and snacks.bufdelete then
    snacks.bufdelete()
  else
    pcall(vim.cmd, "bdelete")
  end
end

function M.next_tab_cycle()
  leave_insert_or_terminal_mode()

  local ok = pcall(vim.cmd, "BufferLineCycleNext")
  if ok then
    return
  end

  local moved = pcall(vim.cmd, "bnext")
  if not moved then
    pcall(vim.cmd, "bfirst")
  end
end

return M
