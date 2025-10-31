M = {}

M.template_stream = function(template)
  local result = {
    model = "gemma3",
    input = { {
      role = "system",
      content = template.system,
    } },
  }

  for _, example in ipairs(template.examples) do
    table.insert(result.input, { role = "user", content = example.user })
    table.insert(result.input, { role = "assistant", content = example.assistant })
  end

  return result
end

return M
