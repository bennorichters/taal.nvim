local Helpers = require("tests.helpers")
local tpl_grammar = require("taal.templates.grammar")
local eq = MiniTest.expect.equality

local cmd = require("taal.commands")
local mock = require("tests.mock")
cmd.setup(mock.buffhelp, mock.template_sender, mock.adapter_model)

Helpers.enable_log()
T = MiniTest.new_set({ hooks = {
  post_case = function()
    mock.reset()
  end,
} })

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

  cmd.grammar({ fargs = { "scratch" } })

  eq(mock.check.template, tpl_grammar)
  eq(mock.check.select_called, true)

  local scratch_buf = mock.values.scratch_buf

  local info1 = get_info1(buf)
  info1.hl_id = 101
  local info2 = get_info2(scratch_buf)
  info2.hl_id = 102
  local info3 = get_info3(buf)
  info3.hl_id = 103
  local info4 = get_info4(scratch_buf)
  info4.hl_id = 104

  eq(cmd.all_diff_info, { info1, info2, info3, info4 })

  info1 = get_info1(buf)
  info2 = get_info2(scratch_buf)
  info3 = get_info3(buf)
  info4 = get_info4(scratch_buf)
  eq(mock.check.add_hl_group_info, { info1, info2, info3, info4 })
end

T["suggest_grammar"] = function()
  cmd.grammar({ fargs = {} })

  local buf_nr = mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  info1.hl_id = 101
  local info3 = get_info3(buf_nr)
  info3.hl_id = 102

  eq(cmd.all_diff_info, { info1, info3 })
end

T["apply_suggestion.apply_to_first_word"] = function()
  mock.buffhelp.current_column_nr = function()
    return 15
  end

  local buf_nr = mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  info1.hl_id = 51
  local info3 = get_info3(buf_nr)
  info3.hl_id = 52

  cmd.all_diff_info = { vim.deepcopy(info1), vim.deepcopy(info3) }

  cmd.apply_suggestion()

  local info3_updated = {
    alt_text = "yesterday.",
    buf_nr = 1,
    col_end = 37,
    col_start = 26,
    hl_group = "KittIssue",
    line_nr = 1,
  }

  info3_updated.hl_id = 52
  eq(mock.check.add_hl_group_info, { info3_updated })

  info3_updated.hl_id = 101
  eq(cmd.all_diff_info, { info3_updated })

  eq(
    mock.check.replace_text_info,
    { { buf_nr, 1, info1.col_start, info1.col_end, info1.alt_text } }
  )

  mock.buffhelp.current_column_nr = nil
end

T["apply_suggestion.apply_to_second_word"] = function()
  mock.buffhelp.current_column_nr = function()
    return 30
  end

  local buf_nr = mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  info1.hl_id = 51
  local info3 = get_info3(buf_nr)
  info3.hl_id = 52

  cmd.all_diff_info = { vim.deepcopy(info1), vim.deepcopy(info3) }

  cmd.apply_suggestion()

  eq(cmd.all_diff_info, { info1 })

  -- add_hl_group should not have been called and this check value is not set
  eq(not mock.check.add_hl_group_info, true)

  -- delete_hl_group should have been called once
  eq(mock.check.delete_hl_group_info, { { 1, 52 } })

  eq(
    mock.check.replace_text_info,
    { { buf_nr, 1, info3.col_start, info3.col_end, info3.alt_text } }
  )

  mock.buffhelp.current_column_nr = nil
end

return T
