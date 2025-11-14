return function(template, user_input)
  local json = vim.fn.json_encode(user_input)
  local stripped = string.sub(json, 2, string.len(json) - 1)
  return string.format(vim.fn.json_encode(template), stripped)
end
