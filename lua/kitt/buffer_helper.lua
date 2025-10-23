local log = require("kitt.log")

local M = {}

M.add_hl_group = function(info)
  log.fmt_trace("add_hl_group info=%s", info)

  return vim.api.nvim_buf_set_extmark(
    info.buf_nr,
    _G.kitt_ns,
    info.line_nr - 1,
    info.col_start,
    { end_row = info.line_nr - 1, end_col = info.col_end, hl_group = info.hl_group }
  )
end

M.text_under_cursor = function()
  local line_number = vim.fn.line(".")
  return vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
end

M.visual_selection = function()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end

  return table.concat(lines, "\n")
end

return M
