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
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      float = {
        transparent = true,
        solid = false,
      },
      term_colors = true,
      dim_inactive = {
        enabled = true,
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
            return {
              normal = {
                a = { bg = "#f38ba8", fg = colors.base, gui = "bold" },
                b = { bg = colors.surface0, fg = "#f38ba8" },
              },
              insert = {
                a = { bg = colors.peach, fg = colors.base, gui = "bold" },
                b = { bg = colors.surface0, fg = colors.peach },
              },
              terminal = {
                a = { bg = colors.peach, fg = colors.base, gui = "bold" },
                b = { bg = colors.surface0, fg = colors.peach },
              },
              command = {
                a = { bg = colors.peach, fg = colors.base, gui = "bold" },
                b = { bg = colors.surface0, fg = colors.peach },
              },
              visual = {
                a = { bg = "#f38ba8", fg = colors.base, gui = "bold" },
                b = { bg = colors.surface0, fg = "#f38ba8" },
              },
              replace = {
                a = { bg = colors.maroon, fg = colors.base, gui = "bold" },
                b = { bg = colors.surface0, fg = colors.maroon },
              },
              inactive = {
                a = { fg = "#f38ba8" },
                b = { fg = colors.surface1, gui = "bold" },
                c = { fg = colors.overlay0 },
              },
            }
          end,
        },
        mini = { indentscope_color = "lavender" },
        snacks = { enabled = true, indent_scope_color = "lavender" },
      },
      custom_highlights = function(colors)
        return {
          Normal = { bg = colors.none },
          NormalNC = { bg = colors.none },
          SignColumn = { bg = colors.none },
          EndOfBuffer = { bg = colors.none },
          CursorLineNr = { fg = colors.lavender, style = { "bold" } },
          LineNr = { fg = colors.surface2 },
          FloatBorder = { fg = colors.surface2, bg = colors.none },
          FloatTitle = { fg = colors.blue, style = { "bold" } },
          NormalFloat = { bg = colors.none },
          Pmenu = { bg = colors.none },
          PmenuSel = { bg = colors.surface0, style = { "bold" } },
          Search = { bg = colors.yellow, fg = colors.base },
          CurSearch = { bg = colors.peach, fg = colors.base },
          IncSearch = { bg = colors.peach, fg = colors.base },
          Visual = { bg = colors.surface1 },
          WinSeparator = { fg = colors.surface1 },
          DiagnosticVirtualTextError = { bg = colors.none },
          DiagnosticVirtualTextWarn = { bg = colors.none },
          DiagnosticVirtualTextInfo = { bg = colors.none },
          DiagnosticVirtualTextHint = { bg = colors.none },
          SnacksDashboardHeader = { fg = "#f38ba8" },
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
