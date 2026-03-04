local M = {}

local close_all_armed = false
local arm_token = 0

local function is_opencode_buffer(buf)
  local name = (vim.api.nvim_buf_get_name(buf) or ""):lower()
  local ft = (vim.bo[buf].filetype or ""):lower()
  local term_title = ""
  pcall(function()
    term_title = tostring(vim.b[buf].term_title or ""):lower()
  end)
  return name:find("opencode", 1, true) ~= nil
    or ft:find("opencode", 1, true) ~= nil
    or term_title:find("opencode", 1, true) ~= nil
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

  local current_buf = vim.api.nvim_get_current_buf()
  if is_opencode_buffer(current_buf) then
    vim.schedule(function()
      local stopped = pcall(function()
        require("opencode").stop()
      end)
      if stopped then
        return
      end

      local current_win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_is_valid(current_win) and #vim.api.nvim_tabpage_list_wins(0) > 1 then
        pcall(vim.api.nvim_win_close, current_win, true)
      end
      if vim.api.nvim_buf_is_valid(current_buf) then
        pcall(vim.api.nvim_buf_delete, current_buf, { force = true })
      end
    end)
    return
  end

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
