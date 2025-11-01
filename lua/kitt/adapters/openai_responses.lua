local log = require("kitt.log")
local start_data = "data: "

return {
  template = function(template) end,

  template_stream = function(template) end,

  post_headers = function() end,

  parse = function(json)
    if not json.output then
      log.fmt_error("body doesn't contain json with output: %s", json)
      return nil
    end

    if not type(json.output) == "table" then
      log.fmt_error("output in body is not a table: %s")
      return nil
    end

    local result = nil
    for _, output_el in ipairs(json.output) do
      if
        output_el.type
        and output_el.type == "message"
        and output_el.content
        and type(output_el.content) == "table"
      then
        for _, content_el in ipairs(output_el.content) do
          if content_el.type == "output_text" then
            if result then
              log.fmt_debug("multiple output_text found in output: %s", json)
              return nil
            end
            result = content_el.text
          end
        end
      end
    end

    log.fmt_trace("content=%s", result)
    return result
  end,

  parse_stream = function(stream_data)
    log.fmt_trace("stream_data=%s", stream_data or "---no data received---")

    if not (stream_data and string.sub(stream_data, 1, #start_data) == start_data) then
      log.fmt_trace("doesn't start with %s", start_data)
      return false, nil
    end

    local data_part = string.sub(stream_data, #start_data + 1)
    local status, json = pcall(vim.fn.json_decode, data_part)

    if not status then
      log.fmt_trace("Could not parse json: %s", data_part)
      return false, nil
    end

    if not json.type then
      log.fmt_trace("doesn't contain json with type")
      return false, nil
    end

    if json.type == "response.output_text.done" then
      log.fmt_trace("done")
      return true, nil
    end

    if json.type == "response.output_text.delta" and json.delta then
      log.fmt_trace("found delta: %s", json.delta)
      return false, json.delta
    end

    log.fmt_trace("no delta found")
    return false, nil
  end,
}
