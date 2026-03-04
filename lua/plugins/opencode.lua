return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    {
      ---@module "snacks"
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {},
        picker = {
          actions = {
            opencode_send = function(...)
              return require("opencode").snacks_picker_send(...)
            end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}

    vim.o.autoread = true

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

    local function focus_left_if_opencode(mode)
      local buf = vim.api.nvim_get_current_buf()
      if not is_opencode_buffer(buf) then
        return "<C-h>"
      end
      if mode == "t" then
        return "<C-\\><C-n><C-w>h"
      end
      if mode == "i" then
        return "<Esc><C-w>h"
      end
      return "<C-w>h"
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

    local function close_opencode_or_tab()
      local buf = vim.api.nvim_get_current_buf()
      if is_opencode_buffer(buf) then
        leave_insert_or_terminal_mode()
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
          if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end)
        return
      end
      require("features.tabs").close_tab_or_all()
    end

    -- Keymaps
    vim.keymap.set({ "n", "x" }, "<C-a>", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })

    vim.keymap.set({ "n", "x" }, "<C-x>", function()
      require("opencode").select()
    end, { desc = "Execute opencode action" })

    vim.keymap.set({ "n", "t" }, "<C-.>", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go", function()
      return require("opencode").operator("@this ")
    end, { desc = "Add range to opencode", expr = true })

    vim.keymap.set("n", "goo", function()
      return require("opencode").operator("@this ") .. "_"
    end, { desc = "Add line to opencode", expr = true })

    vim.keymap.set("n", "<S-C-u>", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll opencode up" })

    vim.keymap.set("n", "<S-C-d>", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll opencode down" })

    -- In opencode UI, use Ctrl+h to jump to the left window.
    vim.keymap.set("n", "<C-h>", function()
      return focus_left_if_opencode("n")
    end, { expr = true, desc = "Opencode: focus left window" })
    vim.keymap.set("i", "<C-h>", function()
      return focus_left_if_opencode("i")
    end, { expr = true, desc = "Opencode: focus left window" })
    vim.keymap.set("t", "<C-h>", function()
      return focus_left_if_opencode("t")
    end, { expr = true, desc = "Opencode: focus left window" })
    vim.keymap.set({ "n", "i", "t" }, "<D-w>", close_opencode_or_tab, {
      silent = true,
      desc = "Close opencode or tab",
    })

    -- Remap original <C-a> and <C-x> to + and -
    vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
    vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
  end,
}
