local function format(template, user_input)
  local stubs = {}
  for _, v in ipairs(user_input) do
    local json = vim.fn.json_encode(v)
    local stripped = string.sub(json, 2, string.len(json) - 1)
    table.insert(stubs, stripped)
  end

  return string.format(vim.fn.json_encode(template), unpack(stubs))
end

return function(template, user_input)
  if user_input == nil then
    return vim.fn.json_encode(template)
  end

  local ar = user_input
  if type(ar) == "string" then
    ar = { ar }
  end

  return format(template, ar)
end
