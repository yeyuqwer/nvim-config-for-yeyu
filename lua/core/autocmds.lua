local group = vim.api.nvim_create_augroup("lawliet_core_autocmds", { clear = true })

local function canAutoSave(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  if not vim.bo[buf].modified or not vim.bo[buf].modifiable or vim.bo[buf].readonly then
    return false
  end

  if vim.bo[buf].buftype ~= "" then
    return false
  end

  return vim.api.nvim_buf_get_name(buf) ~= ""
end

local function autoSaveBuffer(buf)
  if not canAutoSave(buf) then
    return
  end

  vim.api.nvim_buf_call(buf, function()
    -- Persist file contents without piggybacking on save-time automations.
    local ok, err = pcall(vim.cmd, "silent noautocmd update")
    if ok then
      return
    end

    vim.schedule(function()
      vim.notify(("Auto save failed: %s"):format(err), vim.log.levels.WARN)
    end)
  end)
end

-- When opening `nvim <directory>`, snacks explorer focuses a picker buffer.
-- Built-in `:terminal` cannot start from that buffer, so return focus to a
-- normal editing window after startup.
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function()
    if vim.fn.argc(-1) ~= 1 then
      return
    end

    local arg = vim.fn.argv(0)
    if arg == "" or vim.fn.isdirectory(arg) ~= 1 then
      return
    end

    vim.schedule(function()
      local current = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_win_get_buf(current)
      local ft = vim.bo[buf].filetype
      if ft ~= "snacks_picker_list" and ft ~= "snacks_picker_input" then
        return
      end

      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave", "FocusLost", "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = function(args)
    if vim.fn.pumvisible() == 1 then
      return
    end

    autoSaveBuffer(args.buf)
  end,
})
