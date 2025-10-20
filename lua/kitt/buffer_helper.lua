local differ = require("kitt.diff")
local log = require("kitt.log")

local function add_hlgroup(hlgroup, bufnr, linenr, x_start, x_end, y_text)
  log.fmt_trace(
    "highlightgroup=%s, bufnr=%s, linenr=%s, x_start=%s, x_end=%s, y_text=%s",
    hlgroup,
    bufnr,
    linenr,
    x_start,
    x_end,
    y_text
  )

  local id = vim.api.nvim_buf_set_extmark(
    bufnr,
    _G.kitt_ns,
    linenr - 1,
    x_start,
    { end_row = linenr - 1, end_col = x_end, hl_group = hlgroup }
  )

  return {
    line = linenr,
    a_start = x_start,
    a_end = x_end,
    b_text = y_text,
    matchid = id,
  }
end

local M = {}

M.current_line = function()
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

M.apply_diff_hlgroup = function(a, b)
  log.trace("a=%s", a)
  log.trace("b=%s", b)

  local a_group_info = {}
  local b_group_info = {}

  local locations = differ.diff(a.text, b.text)

  for _, loc in ipairs(locations) do
    log.trace("diff info: %s", loc)
    table.insert(
      a_group_info,
      add_hlgroup(a.hlgroup, a.bufnr, a.linenr, loc.a_start, loc.a_end, loc.b_text)
    )
    table.insert(
      b_group_info,
      add_hlgroup(b.hlgroup, b.bufnr, b.linenr, loc.b_start, loc.b_end, loc.a_text)
    )
  end

  return a_group_info, b_group_info
end

return M
