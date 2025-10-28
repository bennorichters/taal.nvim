local log = require("kitt.log")
local start_data = "data: "

local M = {}

M.parse = function(stream_data)
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
end

M.on_chunk = function(parse, response_writer, done_callback)
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

    local done, delta = parse(stream_data)
    if done then
      done_callback(response_writer.bufnr, response_writer.content)
    elseif delta then
      response_writer:write(delta)
    end
  end
end

return M
