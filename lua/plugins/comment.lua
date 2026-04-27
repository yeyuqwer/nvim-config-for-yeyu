local insertColumn

local function moveAfterCommentMarker(ctx)
  local utils = require("Comment.utils")

  if ctx.cmode ~= utils.cmode.comment or ctx.cmotion ~= utils.cmotion.line or ctx.range.srow ~= ctx.range.erow then
    return
  end

  local line = vim.api.nvim_get_current_line()
  local _, column = line:find("^%s*%S+%s?")

  if column then
    insertColumn = column
    vim.api.nvim_win_set_cursor(0, { ctx.range.srow, math.min(column, math.max(#line - 1, 0)) })
  end
end

local function startInsertAt(row, column)
  vim.schedule(function()
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""

    if column >= #line and #line > 0 then
      vim.api.nvim_win_set_cursor(0, { row, #line - 1 })
      vim.cmd("startinsert!")
      return
    end

    vim.api.nvim_win_set_cursor(0, { row, column })
    vim.cmd("startinsert")
  end)
end

local function toggleLine()
  require("Comment.api").toggle.linewise.current()
end

local function toggleLineFromInsert()
  vim.cmd("stopinsert")
  insertColumn = nil
  toggleLine()

  local cursor = vim.api.nvim_win_get_cursor(0)
  startInsertAt(cursor[1], insertColumn or cursor[2])
  insertColumn = nil
end

return {
  {
    "numToStr/Comment.nvim",
    keys = {
      {
        "<D-/>",
        toggleLine,
        mode = "n",
        desc = "Toggle comment line",
      },
      {
        "<D-/>",
        toggleLineFromInsert,
        mode = "i",
        desc = "Toggle comment line",
      },
      { "<D-/>", "gc", mode = "x", remap = true, desc = "Toggle comment selection" },
    },
    opts = {
      post_hook = moveAfterCommentMarker,
    },
  },
}
