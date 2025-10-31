local log = require("kitt.log")

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

M.parse = function(json)
  if not (json.message and json.message.content) then
    log.fmt_error("json does not have message.content: json=%s", json)
    return nil
  end

  local content = json.message.content

  log.fmt_trace("content=%s", content)
  return content
end

M.parse_stream = function(stream_data)
  local status, json = pcall(vim.fn.json_decode, stream_data)

  if not status then
    log.fmt_trace("Could not parse json: %s", stream_data)
    return false, nil
  end

  if json.done == nil then
    log.fmt_trace("doesn't contain json with done")
    return false, nil
  end

  if not (json.message and json.message.content) then
    log.fmt_trace("doesn't contain json with messages.content")
    return false, nil
  end

  return json.done, json.message.content
end

return M
