local log = require("kitt.log")

local M = {}

M.setup = function()
  M.namespace = vim.api.nvim_create_namespace("kitt")
  vim.api.nvim_set_hl(0, "KittIssue", { bg = "DarkRed", fg = "White" })
  vim.api.nvim_set_hl(0, "KittImprovement", { bg = "DarkGreen", fg = "White" })
end

M.current_buffer_nr = function()
  return vim.api.nvim_get_current_buf()
end

M.current_line_nr = function()
  return vim.fn.line(".")
end

M.current_column_nr = function()
  return vim.fn.col(".")
end

M.add_hl_group = function(info)
  log.fmt_trace("add_hl_group info=%s", info)

  return vim.api.nvim_buf_set_extmark(
    info.buf_nr,
    M.namespace,
    info.line_nr - 1,
    info.col_start,
    { end_row = info.line_nr - 1, end_col = info.col_end, hl_group = info.hl_group }
  )
end

M.delete_hl_group = function(buf_nr, extmark_id)
  vim.api.nvim_buf_del_extmark(buf_nr, M.namespace, extmark_id)
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

M.set_lines = function(line_nr, content)
  vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { content })
end

return M
