local function get_function_names(bufnr)
  local parser = vim.treesitter.get_parser(bufnr)
  local tree = parser:parse()[1]
  local query = vim.treesitter.query.parse(
    parser:lang(),
    '(function_declaration name: (identifier) @name)'
  )
  local names = {}
  for _, node in query:iter_captures(tree:root(), bufnr) do
    table.insert(names, vim.treesitter.get_node_text(node, bufnr))
  end
  return names
end
