local log = require("kitt.log")
local response_writer = require("kitt.response_writer")

local function encode_text(text)
  local encoded_text = vim.fn.json_encode(text)
  return string.sub(encoded_text, 2, string.len(encoded_text) - 1)
end

local function on_chunk_wrap(parse, writer, done_callback)
  return function(error, stream_data)
    if error then
      local msg = string.format(
        "error in stream call back: error=%s, stream_data=%s",
        error,
        vim.inspect(stream_data)
      )
      log.fmt_error(msg)
      vim.notify(msg, vim.log.levels.ERROR)
      return
    end

    log.fmt_trace("on_chunk: stream_data=%s", stream_data or "--no stream_data--")

    local done, delta = parse(stream_data)
    if done then
      done_callback(writer.bufnr, writer.content)
    elseif delta then
      writer:write(delta)
    end
  end
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

return function(adapter, post, timeout)
  local function send_request(body_content, extra_opts)
    log.fmt_trace(
      "posting with endpoint=%s, extra_opts=%s, body=%s",
      adapter.endpoint,
      extra_opts,
      body_content
    )

    local opts = {
      body = body_content,
      headers = adapter.post_headers().headers,
    }

    if extra_opts then
      opts = vim.tbl_deep_extend("error", opts, extra_opts)
    end

    return post(adapter.endpoint, opts)
  end

  local M = {}

  M.send = function(template, ...)
    local adapter_template = adapter.template(template)
    local body_content = format_template(adapter_template, ...)

    local response = send_request(body_content, { timeout = timeout })
    log.fmt_trace(
      "plain request response: %s",
      response and response.status and vim.inspect(response) or "---no valid response---"
    )
    if response and response.status and response.status == 200 then
      local status, json = pcall(vim.fn.json_decode, response.body)

      if not status then
        log.fmt_error("Could not parse json: %s", response.body or "--no body--")
        return nil
      end

      local content = adapter.parse(json)
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

  M.stream = function(callback, template, ...)
    local adapter_template = adapter.template_stream(template)
    local body_content = format_template(adapter_template, ...)

    local writer = response_writer:new()
    writer:create_scratch_buffer()

    local on_chunk = on_chunk_wrap(adapter.parse_stream, writer, callback)
    local extra_opts = {
      stream = vim.schedule_wrap(on_chunk),
      raw = { "--tcp-nodelay", "--no-buffer" },
    }

    send_request(body_content, extra_opts)
  end

  return M
end
