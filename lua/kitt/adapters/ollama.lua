local function convert(template)
  local result = {
    model = "gemma3",
    input = { { role = "system", content = template.system } },
  }

  for _, example in ipairs(template.examples) do
    table.insert(result.input, { role = "user", content = example.user })
    table.insert(result.input, { role = "assistant", content = example.assistant })
  end

  return result
end

M = {}

M.template = function(template)
  return convert(template)
end

M.template_stream = function(template)
  local result = convert(template)
  result.stream = true
  return result
end

M.parse = function(response)
  return response
end

M.parse_stream = function(response)
  return response
end

return M
