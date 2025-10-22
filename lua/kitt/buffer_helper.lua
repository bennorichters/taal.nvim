local differ = require("kitt.diff")
local log = require("kitt.log")

local M = {}

M.add_hl_group = function(info)
  log.fmt_trace("info=%s", info)

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

M.apply_diff_hl_groups = function(a, b)
  log.trace("a=%s", a)
  log.trace("b=%s", b)

  local diff_info = {}
  local locations = differ.diff(a.text, b.text)

  for _, loc in ipairs(locations) do
    log.trace("diff info: %s", loc)

    local info_a = {
      buf_nr = a.buf_nr,
      line_nr = a.line_nr,
      col_start = loc.a_start,
      col_end = loc.a_end,
      hl_group = a.hl_group,
      alt_text = loc.b_text,
    }
    info_a.extmark_id = M.add_hl_group(info_a)
    table.insert(diff_info, info_a)

    local info_b = {
      buf_nr = b.buf_nr,
      line_nr = b.line_nr,
      col_start = loc.b_start,
      col_end = loc.b_end,
      hl_group = b.hl_group,
      alt_text = loc.a_text,
    }
    info_b.extmark_id = M.add_hl_group(info_b)
    table.insert(diff_info, info_b)
  end

  return diff_info
end

return M
