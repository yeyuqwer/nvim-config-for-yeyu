local M = {}

function M.remove_unused_imports()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    method = "textDocument/codeAction",
  })
  if #clients == 0 then
    return
  end

  local position_encoding = clients[1].offset_encoding or "utf-16"
  local params = vim.lsp.util.make_range_params(0, position_encoding)
  params.context = {
    diagnostics = vim.diagnostic.get(bufnr),
    only = {
      "source.removeUnusedImports",
      "source.removeUnusedImports.ts",
    },
  }

  local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000) or {}
  local actions = {}

  for client_id, response in pairs(responses) do
    for _, action in ipairs(response.result or {}) do
      actions[#actions + 1] = {
        action = action,
        client_id = client_id,
      }
    end
  end

  if #actions == 0 then
    return
  end

  table.sort(actions, function(a, b)
    local a_preferred = a.action.isPreferred == true
    local b_preferred = b.action.isPreferred == true
    if a_preferred ~= b_preferred then
      return a_preferred
    end

    local a_kind = a.action.kind or ""
    local b_kind = b.action.kind or ""
    if a_kind ~= b_kind then
      return a_kind < b_kind
    end

    return (a.action.title or "") < (b.action.title or "")
  end)

  local selected = actions[1]
  local action = selected.action
  local client = vim.lsp.get_client_by_id(selected.client_id)

  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client and client.offset_encoding or "utf-16")
  end

  local command = action.command
  if not command then
    return
  end

  if type(command) == "table" then
    if client and client.supports_method("workspace/executeCommand") then
      client:exec_cmd(command, { bufnr = bufnr })
    else
      vim.lsp.buf.execute_command(command)
    end
    return
  end

  vim.lsp.buf.execute_command({
    command = command,
    arguments = action.arguments,
  })
end

return M
