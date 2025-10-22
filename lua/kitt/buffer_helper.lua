local differ = require("kitt.diff")
local log = require("kitt.log")

local function add_hl_group(bufnr, linenr, hl_group, hl_start, hl_end, diff_text)
  log.fmt_trace(
    "bufnr=%s, linenr=%s, highlightgroup=%s, hl_start=%s, hl_end=%s, diff_text=%s",
    bufnr,
    linenr,
    hl_group,
    hl_start,
    hl_end,
    diff_text
  )

  local id = vim.api.nvim_buf_set_extmark(
    bufnr,
    _G.kitt_ns,
    linenr - 1,
    hl_start,
    { end_row = linenr - 1, end_col = hl_end, hl_group = hl_group }
  )

  return {
    bufnr = bufnr,
    linenr = linenr,
    a_start = hl_start,
    a_end = hl_end,
    b_text = diff_text,
    matchid = id,
  }
end

local M = {}

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
    table.insert(
      diff_info,
      add_hl_group(a.bufnr, a.linenr, a.hl_group, loc.a_start, loc.a_end, loc.b_text)
    )
    table.insert(
      diff_info,
      add_hl_group(b.bufnr, b.linenr, b.hl_group, loc.b_start, loc.b_end, loc.a_text)
    )
  end

  return diff_info
end

return M
