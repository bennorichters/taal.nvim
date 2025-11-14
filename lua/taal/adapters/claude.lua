local log = require("taal.log")
local start_data = "data: "

local function convert(template, model)
  local result = {
    model = model,
    max_tokens = 1024,
    system = template.system,
    messages = {},
  }

  if template.examples then
    for _, example in ipairs(template.examples) do
      table.insert(result.messages, { role = "user", content = example.user })
      table.insert(result.messages, { role = "assistant", content = example.assistant })
    end
  end

  if template.message then
    table.insert(result.messages, { role = "user", content = template.message })
  end

  return result
end

return {
  endpoint = function(self)
    return self.url .. "/v1/messages"
  end,

  post_headers = function()
    local key = os.getenv("CLAUDE_API_KEY")
    return {
      headers = {
        content_type = "application/json",
        anthropic_version = "2023-06-01",
        x_api_key = key,
      },
    }
  end,

  template = function(template, model)
    return convert(template, model)
  end,

  template_stream = function(template, model)
    local result = convert(template, model)
    result.stream = true
    return result
  end,

  parse = function(json)
    if not json.content then
      log.fmt_error("body doesn't contain json with content: %s", json)
      return nil
    end

    if not json.content[1].text then
      log.fmt_error("body doesn't contain json with content[1].text: %s", json)
      return nil
    end

    return json.content[1].text
  end,

  parse_stream = function(stream_data)
    if not (stream_data and string.sub(stream_data, 1, #start_data) == start_data) then
      log.fmt_trace("doesn't start with %s", start_data)
      return false, nil
    end

    local data_part = string.sub(stream_data, #start_data + 1)
    local status, json = pcall(vim.fn.json_decode, data_part)

    if not status then
      log.fmt_trace("Could not parse json: %s", stream_data or "--no stream_data--")
      return false, nil
    end

    if not json.type then
      log.fmt_error("json.type does not exist. json=%s", json)
      return nil
    end

    if json.type == "content_block_stop" then
      log.fmt_trace('json.type="content_block_stop". json=%s', json)
      return true, nil
    end

    if json.type ~= "content_block_delta" then
      log.fmt_trace('json.type is not "content_block_delta". json=%s', json)
      return false, nil
    end

    if
      not (json.delta and json.delta.type and json.delta.type == "text_delta" and json.delta.text)
    then
      json.fmt_trace('no json.delta.type="text_delta" with json.delta.text found. json=%s', json)
      return false, nil
    end

    return false, json.delta.text
  end,
}
