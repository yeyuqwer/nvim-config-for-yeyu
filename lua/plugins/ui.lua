local function readDotHeader(path)
  local rawLines = vim.fn.readfile(path)
  return table.concat(rawLines, "\n")
end

local function dashboardPaneCount(dashboard)
  local paneWidth = dashboard.opts.width + dashboard.opts.pane_gap
  return math.max(1, math.floor((dashboard._size.width + dashboard.opts.pane_gap) / paneWidth))
end

local function padHeader(header, columns)
  if columns <= 0 then
    return header
  end

  local padding = string.rep(" ", columns)
  local lines = vim.split(header, "\n", { plain = true })
  for index, line in ipairs(lines) do
    lines[index] = padding .. line
  end

  return table.concat(lines, "\n")
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
          NoiceLspDoc = { fg = colors.text, bg = transparent },
          NoiceLspDocBorder = { fg = colors.blue, bg = transparent },
          BlinkCmpDoc = { fg = colors.text, bg = transparent },
          BlinkCmpDocBorder = { fg = colors.blue, bg = transparent },
          BlinkCmpDocSeparator = { fg = colors.surface1, bg = transparent },
          BlinkCmpMenu = { fg = colors.text, bg = transparent },
          BlinkCmpMenuBorder = { fg = colors.surface2, bg = transparent },
          BlinkCmpMenuSelection = { fg = colors.text, bg = colors.surface0, style = { "bold" } },
          BlinkCmpSignatureHelp = { fg = colors.text, bg = transparent },
          BlinkCmpSignatureHelpBorder = { fg = colors.blue, bg = transparent },
          BlinkCmpSignatureHelpActiveParameter = { fg = colors.blue, bg = transparent, style = { "bold" } },
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
    "folke/noice.nvim",
    opts = function(_, opts)
      opts.views = opts.views or {}
      opts.views.hover = vim.tbl_deep_extend("force", opts.views.hover or {}, {
        anchor = "NW",
        border = {
          style = "rounded",
          padding = { 0, 1 },
        },
        position = { row = 2, col = 0 },
        size = {
          width = "auto",
          height = "auto",
          max_width = 96,
          max_height = 12,
        },
        win_options = {
          winblend = 0,
          winhighlight = {
            Normal = "NoiceLspDoc",
            FloatBorder = "NoiceLspDocBorder",
            EndOfBuffer = "NoiceLspDoc",
          },
          wrap = true,
          linebreak = true,
        },
      })

      opts.lsp = opts.lsp or {}
      opts.lsp.documentation = opts.lsp.documentation or {}
      opts.lsp.documentation.opts = vim.tbl_deep_extend("force", opts.lsp.documentation.opts or {}, {
        win_options = {
          winblend = 0,
          winhighlight = {
            Normal = "NoiceLspDoc",
            FloatBorder = "NoiceLspDocBorder",
            EndOfBuffer = "NoiceLspDoc",
          },
        },
      })
      opts.lsp.hover = opts.lsp.hover or {}
      opts.lsp.hover.opts = vim.tbl_deep_extend("force", opts.lsp.hover.opts or {}, {
        anchor = "NW",
        position = { row = 2, col = 0 },
      })
      opts.lsp.signature = opts.lsp.signature or {}
      opts.lsp.signature.opts = vim.tbl_deep_extend("force", opts.lsp.signature.opts or {}, {
        anchor = "NW",
        position = { row = 2, col = 0 },
        size = {
          width = "auto",
          height = "auto",
          max_width = 96,
          max_height = 8,
        },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        always_show_bufferline = false,
        auto_toggle_bufferline = true,
        indicator = {
          style = "underline",
        },
        separator_style = { "", "" },
        show_buffer_close_icons = false,
        show_close_icon = false,
        show_tab_indicators = true,
        tab_size = 22,
        max_name_length = 24,
        modified_icon = "●",
        hover = {
          enabled = true,
          delay = 150,
          reveal = { "close" },
        },
      })
      if (vim.g.colors_name or ""):find("catppuccin") then
        opts.highlights = function()
          local colors = require("catppuccin.palettes").get_palette()
          local fillBg = "NONE"
          local activeBg = colors.surface0
          local inactiveBg = fillBg
          local visibleBg = fillBg
          local activeFg = colors.text
          local inactiveFg = colors.overlay1
          local mutedFg = colors.overlay0
          local accent = colors.pink
          local selectedStyle = { bold = true, underdouble = true, sp = accent }

          return {
            fill = { bg = fillBg },
            background = { fg = inactiveFg, bg = inactiveBg },
            buffer_visible = { fg = colors.subtext1, bg = visibleBg },
            buffer_selected = vim.tbl_extend("force", { fg = activeFg, bg = activeBg }, selectedStyle),
            duplicate = { fg = mutedFg, bg = inactiveBg },
            duplicate_visible = { fg = mutedFg, bg = visibleBg },
            duplicate_selected = vim.tbl_extend("force", { fg = colors.subtext1, bg = activeBg }, selectedStyle),
            separator = { fg = inactiveBg, bg = fillBg },
            separator_visible = { fg = visibleBg, bg = fillBg },
            separator_selected = { fg = activeBg, bg = fillBg },
            indicator_visible = { fg = visibleBg, bg = visibleBg },
            indicator_selected = { fg = accent, bg = activeBg, underdouble = true, sp = accent },
            modified = { fg = colors.peach, bg = inactiveBg },
            modified_visible = { fg = colors.peach, bg = visibleBg },
            modified_selected = { fg = colors.peach, bg = activeBg },
            close_button = { fg = mutedFg, bg = inactiveBg },
            close_button_visible = { fg = mutedFg, bg = visibleBg },
            close_button_selected = { fg = colors.red, bg = activeBg },
            diagnostic = { fg = mutedFg, bg = inactiveBg },
            diagnostic_visible = { fg = mutedFg, bg = visibleBg },
            diagnostic_selected = { fg = colors.subtext1, bg = activeBg, underdouble = true, sp = accent },
            hint = { fg = colors.teal, bg = inactiveBg },
            hint_visible = { fg = colors.teal, bg = visibleBg },
            hint_selected = vim.tbl_extend("force", { fg = colors.teal, bg = activeBg }, selectedStyle),
            hint_diagnostic = { fg = colors.teal, bg = inactiveBg },
            hint_diagnostic_visible = { fg = colors.teal, bg = visibleBg },
            hint_diagnostic_selected = { fg = colors.teal, bg = activeBg },
            info = { fg = colors.sky, bg = inactiveBg },
            info_visible = { fg = colors.sky, bg = visibleBg },
            info_selected = vim.tbl_extend("force", { fg = colors.sky, bg = activeBg }, selectedStyle),
            info_diagnostic = { fg = colors.sky, bg = inactiveBg },
            info_diagnostic_visible = { fg = colors.sky, bg = visibleBg },
            info_diagnostic_selected = { fg = colors.sky, bg = activeBg },
            warning = { fg = colors.yellow, bg = inactiveBg },
            warning_visible = { fg = colors.yellow, bg = visibleBg },
            warning_selected = vim.tbl_extend("force", { fg = colors.yellow, bg = activeBg }, selectedStyle),
            warning_diagnostic = { fg = colors.yellow, bg = inactiveBg },
            warning_diagnostic_visible = { fg = colors.yellow, bg = visibleBg },
            warning_diagnostic_selected = { fg = colors.yellow, bg = activeBg },
            error = { fg = colors.red, bg = inactiveBg },
            error_visible = { fg = colors.red, bg = visibleBg },
            error_selected = vim.tbl_extend("force", { fg = colors.red, bg = activeBg }, selectedStyle),
            error_diagnostic = { fg = colors.red, bg = inactiveBg },
            error_diagnostic_visible = { fg = colors.red, bg = visibleBg },
            error_diagnostic_selected = { fg = colors.red, bg = activeBg },
            numbers = { fg = mutedFg, bg = inactiveBg },
            numbers_visible = { fg = mutedFg, bg = visibleBg },
            numbers_selected = vim.tbl_extend("force", { fg = accent, bg = activeBg }, selectedStyle),
            tab = { fg = inactiveFg, bg = inactiveBg },
            tab_selected = vim.tbl_extend("force", { fg = activeFg, bg = activeBg }, selectedStyle),
            tab_separator = { fg = inactiveBg, bg = fillBg },
            tab_separator_selected = { fg = activeBg, bg = fillBg },
          }
        end
      end
    end,
  },

  {
    "snacks.nvim",
    keys = {
      {
        "<leader>i",
        function()
          Snacks.image.hover()
        end,
        desc = "Preview image at cursor",
      },
    },
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.image = vim.tbl_deep_extend("force", opts.image or {}, {
        enabled = true,
        doc = {
          enabled = true,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
      })
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
      local dotFile = vim.fn.stdpath("config") .. "/dot-art.md"
      local dotHeader = readDotHeader(dotFile)
      opts.dashboard.preset.header = dotHeader

      opts.dashboard.width = 28

      local dashboardKeys = opts.dashboard.preset.keys
      local keySplitIndex = math.ceil(#dashboardKeys / 2)
      for index, item in ipairs(dashboardKeys) do
        if index > keySplitIndex then
          item.pane = 2
        else
          item.pane = 1
        end
      end

      local headerLineCount = #vim.split(opts.dashboard.preset.header, "\n", { plain = true })
      local function centeredHeader(dashboard)
        local paneCount = dashboardPaneCount(dashboard)
        local headerOffset = 0

        if paneCount > 1 then
          headerOffset = dashboard.opts.width + dashboard.opts.pane_gap
        end

        return {
          header = padHeader(opts.dashboard.preset.header, headerOffset),
          padding = 0,
          pane = 1,
        }
      end

      local function rightHeaderSpacer(dashboard)
        local paneCount = dashboardPaneCount(dashboard)
        if paneCount < 2 then
          return nil
        end

        return { text = string.rep("\n", headerLineCount - 1), pane = 2 }
      end

      opts.dashboard.sections = {
        centeredHeader,
        rightHeaderSpacer,
        { section = "keys",                      gap = 1,    padding = 1 },
        { section = "startup",                   pane = 1 },
      }
    end,
  },
}
