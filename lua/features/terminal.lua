local M = {}

local explorer = require("features.explorer")
local terminals_by_tab = {}

local excluded_filetypes = {
  snacks_dashboard = true,
  snacks_layout_box = true,
  snacks_picker_preview = true,
  snacks_picker_input = true,
  snacks_picker_list = true,
}

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

local function find_terminal_parent_win()
  local current = vim.api.nvim_get_current_win()
  local best_win = nil
  local best_score = -math.huge

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      if buf and vim.api.nvim_buf_is_valid(buf) then
        local ft = vim.bo[buf].filetype
        local bt = vim.bo[buf].buftype
        local score = vim.api.nvim_win_get_width(win)

        if win == current then
          score = score + 200
        end
        if vim.w[win].snacks_main then
          score = score + 10000
        end
        if bt == "" then
          score = score + 4000
        elseif bt == "terminal" then
          score = score - 6000
        else
          score = score - 3000
        end
        if ft == "" then
          score = score + 500
        end
        if excluded_filetypes[ft] then
          score = score - 10000
        end

        if score > best_score then
          best_score = score
          best_win = win
        end
      end
    end
  end

  if best_win and vim.api.nvim_win_is_valid(best_win) then
    return best_win
  end
  if current and vim.api.nvim_win_is_valid(current) and vim.api.nvim_win_get_config(current).relative == "" then
    return current
  end
  return 0
end

local function is_project_terminal_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf) and vim.b[buf].lawliet_project_terminal == true
end

local function find_visible_terminal_win(tabpage)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      return win, buf, is_project_terminal_buf(buf)
    end
  end

  return nil, nil, false
end

local function prune_tab_terminal(tabpage)
  local buf = terminals_by_tab[tabpage]
  if not is_project_terminal_buf(buf) then
    terminals_by_tab[tabpage] = nil
    return nil
  end
  return buf
end

local function open_terminal_in_parent(parent_win, tabpage)
  local terminal_buf = prune_tab_terminal(tabpage)
  local terminal_win

  vim.api.nvim_win_call(parent_win, function()
    vim.cmd("belowright split")
    terminal_win = vim.api.nvim_get_current_win()

    if terminal_buf then
      vim.api.nvim_win_set_buf(terminal_win, terminal_buf)
      return
    end

    vim.cmd("enew")
    terminal_buf = vim.api.nvim_get_current_buf()
    terminals_by_tab[tabpage] = terminal_buf

    vim.b[terminal_buf].lawliet_project_terminal = true
    vim.bo[terminal_buf].bufhidden = "hide"
    vim.bo[terminal_buf].buflisted = false

    local cwd = explorer.root()
    vim.fn.termopen(vim.o.shell, { cwd = cwd })

    vim.api.nvim_create_autocmd("BufWipeout", {
      buffer = terminal_buf,
      once = true,
      callback = function()
        for tab, buf in pairs(terminals_by_tab) do
          if buf == terminal_buf then
            terminals_by_tab[tab] = nil
          end
        end
      end,
    })
  end)

  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_set_current_win(terminal_win)
    vim.cmd("startinsert")
  end
end

function M.toggle_project_terminal()
  leave_insert_or_terminal_mode()

  local tabpage = vim.api.nvim_get_current_tabpage()
  local terminal_win = find_visible_terminal_win(tabpage)
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_win_close(terminal_win, true)
    return
  end

  local parent_win = find_terminal_parent_win()
  open_terminal_in_parent(parent_win, tabpage)
end

return M
