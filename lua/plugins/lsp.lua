return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "typescript-language-server",
      },
    },
    opts_extend = { "ensure_installed" },
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.lua_ls = opts.servers.lua_ls or {}
      opts.servers.ts_ls = opts.servers.ts_ls or {}

      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}
      table.insert(opts.servers["*"].keys, { "K", false })
      table.insert(opts.servers["*"].keys, { "<leader>ch", function() return vim.lsp.buf.hover() end, desc = "Hover" })
    end,
  },
}
