local log = require("taal.log")
local start_data = "data: "

local function convert(template)
  local result = { contents = {} }

  if template.system then
    result.system_instruction = { parts = { { text = template.system } } }
  end

  if template.examples then
    for _, example in ipairs(template.examples) do
      table.insert(result.contents, { role = "user", parts = { { text = example.user } } })
      table.insert(result.contents, { role = "model", parts = { { text = example.assistant } } })
    end
  end

  if template.message then
    table.insert(result.contents, { role = "user", parts = { { text = template.message } } })
  end

  return result
end

local function extract_text(json)
  if
    not (
      json.candidates
      and json.candidates[1]
      and json.candidates[1].content
      and json.candidates[1].content.parts
      and json.candidates[1].content.parts[1]
      and json.candidates[1].content.parts[1].text
    )
  then
    log.fmt_error("json does not contain candidates[1].content.parts[1].text")
    return nil
  end

  local result = json.candidates[1].content.parts[1].text
  log.fmt_trace("extract_text: %s", result)

  return result
end

return {
  endpoint = function(self, model, stream)
    local result = self.url .. "/v1beta/models/" .. model .. ":"

    if stream then
      result = result .. "streamGenerateContent?alt=sse"
    else
      result = result .. "generateContent"
    end

    return result
  end,

  post_headers = function()
    local key = os.getenv("GEMINI_API_KEY")
    return { headers = { content_type = "application/json", x_goog_api_key = key } }
  end,

  template = convert,
  template_stream = convert,
  parse = extract_text,

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

    local delta = extract_text(json)
    if not delta then
      return false, nil
    end

    if json.candidates[1].finishReason then
      log.fmt_trace("parse_stream finishReason=%s", json.candidates[1].finishReason)
      return true, delta
    end

    return false, delta
  end,
}
