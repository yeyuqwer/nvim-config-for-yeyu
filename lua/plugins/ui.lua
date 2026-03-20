local function read_dot_header(path)
  local ok, raw_lines = pcall(vim.fn.readfile, path)
  if not ok or not raw_lines then
    return nil
  end

  local width = 0
  for _, line in ipairs(raw_lines) do
    width = math.max(width, vim.api.nvim_strwidth(line))
  end
  if width == 0 then
    return nil
  end
  return table.concat(raw_lines, "\n"), width
end

return {
  {
    "LazyVim/LazyVim",
    config = function(_, opts)
      opts = opts or {}
      -- Let Nvim detect the terminal/UI background, then load the matching
      -- Catppuccin flavour: `mocha` for dark and `latte` for light.
      opts.colorscheme = "catppuccin"
      require("lazyvim").setup(opts)
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "auto",
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
      term_colors = true,
      dim_inactive = {
        enabled = false,
      },
      styles = {
        loops = { "italic" },
        keywords = { "italic" },
        types = { "bold" },
        properties = { "italic" },
      },
      integrations = {
        indent_blankline = {
          scope_color = "lavender",
        },
        lualine = {
          all = function(colors)
            local transparent = "NONE"
            return {
              normal = {
                a = { bg = colors.pink, fg = colors.base, gui = "bold" },
                b = { bg = transparent, fg = colors.pink },
                c = { bg = transparent, fg = colors.text },
              },
              insert = {
                a = { bg = colors.peach, fg = colors.base, gui = "bold" },
                b = { bg = transparent, fg = colors.peach },
                c = { bg = transparent, fg = colors.text },
              },
              terminal = {
                a = { bg = colors.peach, fg = colors.base, gui = "bold" },
                b = { bg = transparent, fg = colors.peach },
                c = { bg = transparent, fg = colors.text },
              },
              command = {
                a = { bg = colors.peach, fg = colors.base, gui = "bold" },
                b = { bg = transparent, fg = colors.peach },
                c = { bg = transparent, fg = colors.text },
              },
              visual = {
                a = { bg = colors.pink, fg = colors.base, gui = "bold" },
                b = { bg = transparent, fg = colors.pink },
                c = { bg = transparent, fg = colors.text },
              },
              replace = {
                a = { bg = colors.maroon, fg = colors.base, gui = "bold" },
                b = { bg = transparent, fg = colors.maroon },
                c = { bg = transparent, fg = colors.text },
              },
              inactive = {
                a = { bg = transparent, fg = colors.pink },
                b = { bg = transparent, fg = colors.surface1, gui = "bold" },
                c = { bg = transparent, fg = colors.overlay0 },
              },
            }
          end,
        },
        mini = { indentscope_color = "lavender" },
        snacks = { enabled = true, indent_scope_color = "lavender" },
      },
      custom_highlights = function(colors)
        local transparent = "NONE"
        return {
          Normal = { bg = transparent },
          NormalNC = { bg = transparent },
          NormalFloat = { bg = transparent },
          FloatBorder = { fg = colors.surface2, bg = transparent },
          FloatTitle = { fg = colors.blue, bg = transparent, style = { "bold" } },
          SignColumn = { bg = transparent },
          FoldColumn = { bg = transparent },
          EndOfBuffer = { bg = transparent },
          StatusLine = { bg = transparent },
          StatusLineNC = { bg = transparent },
          TabLineFill = { bg = transparent },
          WinBar = { bg = transparent },
          WinBarNC = { bg = transparent },
          Pmenu = { bg = transparent },
          PmenuSbar = { bg = transparent },
          CursorLineNr = { fg = colors.lavender, style = { "bold" } },
          LineNr = { fg = colors.surface2 },
          PmenuSel = { bg = colors.surface0, style = { "bold" } },
          Search = { bg = colors.yellow, fg = colors.base },
          CurSearch = { bg = colors.peach, fg = colors.base },
          IncSearch = { bg = colors.peach, fg = colors.base },
          Visual = { bg = colors.surface1 },
          WinSeparator = { fg = colors.surface1 },
          SnacksDashboardHeader = { fg = colors.pink },
        }
      end,
    },
  },

  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.indicator = vim.tbl_deep_extend("force", opts.options.indicator or {}, {
        style = "underline",
      })
      if (vim.g.colors_name or ""):find("catppuccin") then
        opts.highlights = require("catppuccin.special.bufferline").get_theme({
          styles = { "bold" },
        })
      end
    end,
  },

  {
    "snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.explorer = vim.tbl_deep_extend("force", opts.picker.sources.explorer or {}, {
        hidden = true,
        win = {
          list = {
            keys = {
              ["<CR>"] = "explorer_rename",
            },
          },
        },
      })

      -- * thanks https://emojicombos.com/miku
      local dot_file = vim.fn.stdpath("config") .. "/dot-art.md"
      local dot_header, dot_width = read_dot_header(dot_file)
      if dot_header then
        opts.dashboard.width = math.max(opts.dashboard.width or 60, dot_width)
        opts.dashboard.preset.header = dot_header
      end
      opts.dashboard.preset.keys = vim.tbl_filter(function(item)
        local key = tostring(item.key or "")
        local desc = tostring(item.desc or "")
        local action = tostring(item.action or "")
        if key == "q" or key == "l" or key == "L" then
          return false
        end
        if desc == "Quit" or desc == "Lazy" then
          return false
        end
        if action == ":qa" or action == ":Lazy" then
          return false
        end
        return true
      end, opts.dashboard.preset.keys or {})

      opts.dashboard.sections = {
        { header = opts.dashboard.preset.header, padding = 0 },
        { section = "keys",                      gap = 1,    padding = 1 },
        { section = "startup" },
      }
    end,
  },
}
