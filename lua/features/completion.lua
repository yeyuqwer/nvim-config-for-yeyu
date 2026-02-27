local M = {}

function M.trigger_completion_menu()
  local ok, cmp = pcall(require, "blink.cmp")
  if ok then
    cmp.show()
    cmp.show_signature()
  else
    vim.api.nvim_feedkeys(vim.keycode("<C-Space>"), "n", false)
  end
end

return M
