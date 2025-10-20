local log = require("kitt.log")
local response_writer = require("kitt.response_writer")
local stream_handler = require("kitt.stream")

local function encode_text(text)
  local encoded_text = vim.fn.json_encode(text)
  return string.sub(encoded_text, 2, string.len(encoded_text) - 1)
end

local function openai_extract_content(body)
  local status, json = pcall(vim.fn.json_decode, body)
  if not status then
    log.fmt_error("could not parse body as json", body)
    return nil
  end

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
            log.fmt_debug("multiple output_text found in output: %s", body)
            return nil
          end
          result = content_el.text
        end
      end
    end
  end

  log.fmt_trace("content=%s", result)
  return result
end

return function(send_request, timeout)
  local send_plain_request = function(body_content)
    local response = send_request(body_content, { timeout = timeout })
    log.fmt_trace(
      "plain request response: %s",
      response and response.status and vim.inspect(response) or "---no valid response---"
    )
    if response and response.status and response.status == 200 then
      local content = openai_extract_content(response.body)
      if content then
        return content
      end

      log.fmt_error("response: %s", vim.inspect(response))
      vim.notify("Error processing response", vim.log.levels.ERROR)
    else
      log.fmt_error(
        "response status is not 200. response status=%s. response=%s",
        response.status,
        response
      )
      vim.notify(
        string.format("unexpected response from server: %s", vim.inspect(response)),
        vim.log.levels.ERROR
      )
    end
  end

  local send_stream_request = function(body_content, callback)
    local rw = response_writer:new()
    rw:create_scratch_buffer()
    local process_stream = stream_handler.process_wrap(stream_handler.parse, rw, callback)
    local stream = { stream = vim.schedule_wrap(process_stream) }

    send_request(body_content, stream)
  end

  local function format_template(template, ...)
    local subts = {}
    local count = select("#", ...)
    for i = 1, count do
      local text = select(i, ...)
      table.insert(subts, encode_text(text))
    end

    return string.format(vim.fn.json_encode(template), unpack(subts))
  end

  local M = {}

  M.send = function(template, ...)
    return send_plain_request(format_template(template, ...))
  end

  M.stream = function(template, callback, ...)
    template.stream = true
    send_stream_request(format_template(template, ...), callback)
  end

  return M
end
