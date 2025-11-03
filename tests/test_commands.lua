local Helpers = require("tests.helpers")
local tpl_grammar = require("kitt.templates.grammar")
local eq = MiniTest.expect.equality

local cmd = require("kitt.commands")
local mock = require("tests.mock")
cmd.setup(mock.buffhelp, mock.template_sender, mock.adapter_model)

Helpers.enable_log()
T = MiniTest.new_set()

local function get_info1(buf)
  return {
    alt_text = "brighter",
    buf_nr = buf,
    col_end = 23,
    col_start = 12,
    hl_group = "KittIssue",
    line_nr = 1,
    extmark_id = 42,
  }
end
local function get_info2(buf)
  return {
    alt_text = "more bright",
    buf_nr = buf,
    col_end = 20,
    col_start = 12,
    hl_group = "KittImprovement",
    line_nr = 1,
    extmark_id = 42,
  }
end
local function get_info3(buf)
  return {
    alt_text = "yesterday.",
    buf_nr = buf,
    col_end = 40,
    col_start = 29,
    hl_group = "KittIssue",
    line_nr = 1,
    extmark_id = 42,
  }
end
local function get_info4(buf)
  return {
    alt_text = "yesterdate.",
    buf_nr = buf,
    col_end = 36,
    col_start = 26,
    hl_group = "KittImprovement",
    line_nr = 1,
    extmark_id = 42,
  }
end

T["improve_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()

  cmd.improve_grammar()

  eq(mock.check.template, tpl_grammar)
  eq(mock.check.select_called, true)

  local scratch_buf = mock.values.scratch_buf

  local info1 = get_info1(buf)
  local info2 = get_info2(scratch_buf)
  local info3 = get_info3(buf)
  local info4 = get_info4(scratch_buf)

  eq(cmd.diff_info, { info1, info2, info3, info4 })

  -- the extmark_id wasn't yet set when add_hl_group_info was called
  info1.extmark_id = nil
  info2.extmark_id = nil
  info3.extmark_id = nil
  info4.extmark_id = nil
  eq(mock.check.add_hl_group_info, { info1, info2, info3, info4 })
end

T["suggest_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()
  cmd.suggest_grammar()

  local info1 = get_info1(buf)
  local info3 = get_info3(buf)

  eq(cmd.diff_info, { info1, info3 })
end

T["apply_suggestion"] = function() end

return T
