local function scaled_index(index, src_size, dst_size)
  if src_size <= 1 or dst_size <= 1 then
    return 1
  end
  return math.floor(index * (src_size - 1) / (dst_size - 1)) + 1
end

local function build_dot_header(path, target_width, target_height, scale)
  scale = tonumber(scale) or 1
  target_width = math.max(1, math.floor(target_width * scale + 0.5))
  target_height = math.max(1, math.floor(target_height * scale + 0.5))

  local ok, raw_lines = pcall(vim.fn.readfile, path)
  if not ok or not raw_lines then
    return nil
  end

  local lines = {}
  local src_width = 0
  for _, line in ipairs(raw_lines) do
    if line ~= "" then
      lines[#lines + 1] = line
      src_width = math.max(src_width, vim.fn.strchars(line))
    end
  end
  if #lines == 0 or src_width == 0 then
    return nil
  end

  local out = {}
  local src_height = #lines
  for row = 0, target_height - 1 do
    local src = lines[scaled_index(row, src_height, target_height)] or ""
    local src_line_width = vim.fn.strchars(src)
    local cols = {}

    for col = 0, target_width - 1 do
      local src_col = scaled_index(col, src_width, target_width) - 1
      cols[#cols + 1] = src_col < src_line_width and vim.fn.strcharpart(src, src_col, 1) or " "
    end
    out[#out + 1] = table.concat(cols)
  end

  return table.concat(out, "\n")
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
      local dot_header = build_dot_header(dot_file, 60, 15, 0.5)
      if dot_header then
        opts.dashboard.width = 52
        opts.dashboard.preset.header = dot_header
      end
    end,
  },
}
