local severity_prefix = {
  [vim.diagnostic.severity.ERROR] = "🤣👉🤡 ERROR: ",
  [vim.diagnostic.severity.WARN] = "🤬 WARNING: ",
  [vim.diagnostic.severity.INFO] = "😅 ",
  [vim.diagnostic.severity.HINT] = "😋 ",
}

local virtual_text_namespace = vim.api.nvim_create_namespace("lawliet.highest_severity_virtual_text")

local function highest_severity_per_line(diagnostics)
  local filtered = {}

  for _, diagnostic in ipairs(diagnostics) do
    local current = filtered[diagnostic.lnum]
    if not current
      or diagnostic.severity < current.severity
      or (diagnostic.severity == current.severity and diagnostic.col < current.col)
    then
      filtered[diagnostic.lnum] = diagnostic
    end
  end

  return vim.tbl_values(filtered)
end

local function setup_single_virtual_text_per_line()
  _G.__lawliet_original_diagnostic_virtual_text_handler =
    _G.__lawliet_original_diagnostic_virtual_text_handler or vim.diagnostic.handlers.virtual_text

  local original_virtual_text_handler = _G.__lawliet_original_diagnostic_virtual_text_handler

  local function render(bufnr, opts)
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    if not opts or not opts.virtual_text then
      original_virtual_text_handler.hide(virtual_text_namespace, bufnr)
      return
    end

    local diagnostics = vim.diagnostic.get(bufnr, {
      severity = opts.virtual_text.severity,
    })
    diagnostics = highest_severity_per_line(diagnostics)

    if vim.tbl_isempty(diagnostics) then
      original_virtual_text_handler.hide(virtual_text_namespace, bufnr)
      return
    end

    original_virtual_text_handler.show(virtual_text_namespace, bufnr, diagnostics, opts)
  end

  vim.diagnostic.handlers.virtual_text = {
    show = function(_, bufnr, _, opts)
      render(bufnr, opts)
    end,
    hide = function(_, bufnr)
      render(bufnr, vim.diagnostic.config())
    end,
  }
end

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
      setup_single_virtual_text_per_line()

      opts.servers = opts.servers or {}
      opts.servers.lua_ls = opts.servers.lua_ls or {}
      opts.servers.ts_ls = opts.servers.ts_ls or {}
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        virtual_text = {
          prefix = function(diagnostic)
            return severity_prefix[diagnostic.severity] or "● "
          end,
        },
      })

      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}
      table.insert(opts.servers["*"].keys, { "K", false })
      table.insert(opts.servers["*"].keys, { "<leader>ch", function() return vim.lsp.buf.hover() end, desc = "Hover" })
    end,
  },
}
