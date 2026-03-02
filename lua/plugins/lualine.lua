return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {
            "NvimTree",
            "snacks_dashboard",
          },
        },
        globalstatus = true,
      },
      extensions = {
        "lazy",
        "trouble",
        "toggleterm",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { { "diagnostics", always_visible = true } },
        lualine_z = { "location" },
      },
    },
  },
}
