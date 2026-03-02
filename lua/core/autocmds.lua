local group = vim.api.nvim_create_augroup("lawliet_core_autocmds", { clear = true })

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
