local log = require("taal.log")

local function convert(template, model)
  local result = {
    model = model,
    messages = { { role = "system", content = template.system } },
  }

  if template.examples then
    for _, example in ipairs(template.examples) do
      table.insert(result.messages, { role = "user", content = example.user })
      table.insert(result.messages, { role = "assistant", content = example.assistant })
    end
  end

  table.insert(result.messages, { role = "user", content = "%s" })

  return result
end

return {
  endpoint = function(self)
    return self.url .. "/api/chat"
  end,

  post_headers = function()
    return { headers = { content_type = "application/json" } }
  end,

  template = function(template, model)
    local result = convert(template, model)
    result.stream = false
    return result
  end,

  template_stream = function(template, model)
    local result = convert(template, model)
    result.stream = true
    return result
  end,

  parse = function(json)
    if not (json.message and json.message.content) then
      log.fmt_error("json does not have message.content: json=%s", json)
      return nil
    end

    local content = json.message.content

    log.fmt_trace("content=%s", content)
    return content
  end,

  parse_stream = function(stream_data)
    local status, json = pcall(vim.fn.json_decode, stream_data)

    if not status then
      log.fmt_trace("Could not parse json: %s", stream_data or "--no stream_data--")
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
  end,
}
