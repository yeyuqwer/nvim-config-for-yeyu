return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "biome",
      },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      local biome_filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
      }

      for _, ft in ipairs(biome_filetypes) do
        opts.formatters_by_ft[ft] = { "biome", lsp_format = "never" }
      end
    end,
  },
}
