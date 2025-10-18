local log = require("kitt.log")
local start_data = "data: "

local M = {}

M.parse = function(stream_data)
  log.fmt_trace("stream_data=%s", stream_data or "---no data received---")

  if not (stream_data and string.sub(stream_data, 1, #start_data) == start_data) then
    log.fmt_trace("doesn't start with %s", start_data)
    return false, nil
  end

  local status, json = pcall(vim.fn.json_decode, string.sub(stream_data, #start_data + 1))

  if not (status and json.type) then
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

M.process_wrap = function(parse, ui_select, write)
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
      ui_select()
    elseif delta then
      write(delta)
    end
  end
end

return M
