local function get_line_text(line_number)
  return vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1] or ""
end

local function get_around_entire_region()
  local last_line = vim.api.nvim_buf_line_count(0)
  local last_line_text = get_line_text(last_line)

  return {
    from = { line = 1, col = 1 },
    to = { line = last_line, col = math.max(#last_line_text, 1) },
    vis_mode = "V",
  }
end

local function get_inside_entire_region()
  local line_count = vim.api.nvim_buf_line_count(0)
  local first_nonblank = vim.fn.nextnonblank(1)
  local last_nonblank = vim.fn.prevnonblank(line_count)

  if first_nonblank == 0 or last_nonblank == 0 then
    return get_around_entire_region()
  end

  local first_line_text = get_line_text(first_nonblank)
  local last_line_text = get_line_text(last_nonblank)
  local first_col = first_line_text:find("%S") or 1
  local last_col = last_line_text:match(".*()%S") or 1

  return {
    from = { line = first_nonblank, col = first_col },
    to = { line = last_nonblank, col = last_col },
  }
end

return {
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = function()
      return {
        custom_textobjects = {
          -- Match VSCodeVim/textobj-entire style `ae` / `ie`.
          e = function(ai_type)
            if ai_type == "a" then
              return get_around_entire_region()
            end

            return get_inside_entire_region()
          end,
        },
      }
    end,
  },
}
