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
      opts.formatters = opts.formatters or {}

      local biome_filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
      }
      local c_filetypes = {
        "c",
        "cpp",
        "objc",
        "objcpp",
      }

      for _, ft in ipairs(biome_filetypes) do
        opts.formatters_by_ft[ft] = { "biome", lsp_format = "never" }
      end

      for _, ft in ipairs(c_filetypes) do
        opts.formatters_by_ft[ft] = { "clang-format", lsp_format = "never" }
      end

      opts.formatters["clang-format"] = {
        inherit = true,
        command = "/Library/Developer/CommandLineTools/usr/bin/clang-format",
        prepend_args = {
          "--style={BasedOnStyle: LLVM, IndentWidth: 2, BreakBeforeBraces: Allman}",
        },
      }
    end,
  },
}
