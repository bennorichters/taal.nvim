local Helpers = require("tests.helpers")
local tpl_grammar = require("kitt.templates.grammar")
local eq = MiniTest.expect.equality
local child, T = Helpers.new_child_with_set([[
  mock = require("tests.mock")
  cmd = require("kitt.commands")
  cmd.setup(mock.buffhelp, mock.template_sender, mock.adapter_model)
]])

local function get_info1(buf)
  return {
    alt_text = "brighter",
    buf_nr = buf,
    col_end = 23,
    col_start = 12,
    hl_group = "KittIssue",
    line_nr = 1,
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
  }
end

T["improve_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()

  child.lua("cmd.improve_grammar()")

  eq(child.lua_get("mock.check.template"), tpl_grammar)
  eq(child.lua_get("mock.check.select_called"), true)

  local scratch_buf = child.lua_get("mock.values.scratch_buf")

  local info1 = get_info1(buf)
  local info2 = get_info2(scratch_buf)
  local info3 = get_info3(buf)
  local info4 = get_info4(scratch_buf)

  eq(child.lua_get("mock.check.add_hl_group_info"), { info1, info2, info3, info4 })

  info1.extmark_id = 42
  info2.extmark_id = 42
  info3.extmark_id = 42
  info4.extmark_id = 42

  eq(child.lua_get("cmd.diff_info"), { info1, info2, info3, info4 })
end

T["suggest_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()
  child.lua("cmd.suggest_grammar()")

  local info1 = get_info1(buf)
  info1.extmark_id = 42
  local info3 = get_info3(buf)
  info3.extmark_id = 42

  eq(child.lua_get("cmd.diff_info"), {info1, info3})
end

T["apply_suggestion"] = function() end

return T
