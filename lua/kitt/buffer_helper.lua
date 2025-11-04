local log = require("kitt.log")

local M = {}

M.setup = function()
  M.namespace = vim.api.nvim_create_namespace("kitt")
  log.fmt_trace("buffer_helper.setup kitt namespace=%s", M.namespace)
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
  local extmark_id = vim.api.nvim_buf_set_extmark(
    info.buf_nr,
    M.namespace,
    info.line_nr - 1,
    info.col_start,
    { end_row = info.line_nr - 1, end_col = info.col_end, hl_group = info.hl_group }
  )

  log.fmt_trace(
    "add_hl_group info=%s, namespace=%s, created extmark_id=%s",
    info,
    M.namespace,
    extmark_id
  )

  return extmark_id
end

M.delete_hl_group = function(buf_nr, extmark_id)
  log.fmt_trace(
    "delete_hl_group namespace=%s, buf_nr=%s, extmark_id=%s",
    M.namespace,
    buf_nr,
    extmark_id
  )
  vim.api.nvim_buf_del_extmark(buf_nr, M.namespace, extmark_id)
  local remaining_marks =
    vim.api.nvim_buf_get_extmarks(buf_nr, M.namespace, 0, -1, { details = true })
  log.fmt_trace("delete_hl_group remaining_marks=%s", remaining_marks)
end

M.text_under_cursor = function()
  local line_number = vim.fn.line(".")
  return vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
end

M.visual_selection = function()
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "v" and mode ~= "V" then
    log.fmt_debug("visual_selection: not in visual mode, mode ='%s'. return nil", mode)
    return nil
  end

  local pos_visual_start = vim.fn.getpos("v")
  local start_line, start_col = pos_visual_start[2] - 1, pos_visual_start[3] - 1

  local pos_cursor = vim.fn.getpos(".")
  local end_line, end_col = pos_cursor[2] - 1, pos_cursor[3] - 1

  if end_line < start_line then
    start_line, start_col, end_line, end_col = end_line, end_col, start_line, start_col
  elseif start_line == end_line and end_col < start_col then
    start_col, end_col = end_col, start_col
  end

  log.fmt_trace(
    "visual_selection: start_line=%s, start_col=%s, end_line=%s, end_col=%s",
    start_line,
    start_col,
    end_line,
    end_col
  )

  local selection = vim.api.nvim_buf_get_text(0, start_line, start_col, end_line, end_col, {})
  local one_line = table.concat(selection, "\n")
  log.fmt_trace("visual_selection: selection: %s", one_line)

  return one_line
end

M.set_lines = function(line_nr, content)
  vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { content })
end

M.replace_text = function(buf_nr, line_nr, col_start, col_end, text)
  vim.api.nvim_buf_set_text(buf_nr, line_nr - 1, col_start, line_nr - 1, col_end, { text })
end

return M
