local Cmd = require("taal.commands")
local Helpers = require("tests.helpers")
local Mock = require("tests.mock")

local eq = MiniTest.expect.equality

Cmd.setup(Mock.buffhelp, Mock.template_sender, Mock.adapter_model, Mock.templates)

Helpers.enable_log()
T = MiniTest.new_set({ hooks = {
  post_case = function()
    Mock.reset()
  end,
} })

local function get_info1(buf)
  return {
    alt_text = "brighter",
    buf_nr = buf,
    col_end = 23,
    col_start = 12,
    hl_group = "TaalIssue",
    line_nr = 1,
  }
end
local function get_info2(buf)
  return {
    alt_text = "more bright",
    buf_nr = buf,
    col_end = 20,
    col_start = 12,
    hl_group = "TaalImprovement",
    line_nr = 1,
  }
end
local function get_info3(buf)
  return {
    alt_text = "yesterday.",
    buf_nr = buf,
    col_end = 40,
    col_start = 29,
    hl_group = "TaalIssue",
    line_nr = 1,
  }
end
local function get_info4(buf)
  return {
    alt_text = "yesterdate.",
    buf_nr = buf,
    col_end = 36,
    col_start = 26,
    hl_group = "TaalImprovement",
    line_nr = 1,
  }
end

T["grammar"] = function()
  Cmd.grammar({ fargs = {} })

  local buf_nr = Mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  info1.hl_id = 101
  local info3 = get_info3(buf_nr)
  info3.hl_id = 102

  eq(Cmd.all_diff_info, { info1, info3 })
end

T["grammar_scratch"] = function()
  local buf = vim.api.nvim_get_current_buf()

  Cmd.grammar({ fargs = { "scratch" } })

  eq(Mock.args_store.template_sender.stream[1], Mock.templates.grammar)
  eq(Mock.args_store.template_sender_stream_select_called, true)

  local scratch_buf = Mock.values.buffer_helper.scratch_buf

  local info1 = get_info1(buf)
  info1.hl_id = 101
  local info2 = get_info2(scratch_buf)
  info2.hl_id = 102
  local info3 = get_info3(buf)
  info3.hl_id = 103
  local info4 = get_info4(scratch_buf)
  info4.hl_id = 104

  eq(Cmd.all_diff_info, { info1, info2, info3, info4 })

  info1 = get_info1(buf)
  info2 = get_info2(scratch_buf)
  info3 = get_info3(buf)
  info4 = get_info4(scratch_buf)
  eq(Mock.args_store.buffer_helper.add_hl_group, { info1, info2, info3, info4 })
end

T["hover.first_word"] = function()
  local buf_nr = Mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  Cmd.all_diff_info = { vim.deepcopy(info1) }

  Mock.values.buffer_helper.column_nr = 15

  Cmd.hover()
  eq(Mock.args_store.buffer_helper.show_hover, { "brighter" })
end

T["hover.before_first_word"] = function()
  local buf_nr = Mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  Cmd.all_diff_info = { vim.deepcopy(info1) }

  Cmd.hover()
  eq(Mock.args_store.buffer_helper.show_hover, nil)
end

T["hover.empty_word"] = function()
  local buf_nr = Mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  info1.alt_text = ""
  Cmd.all_diff_info = { vim.deepcopy(info1) }

  Mock.values.buffer_helper.column_nr = 15

  Cmd.hover()
  eq(Mock.args_store.buffer_helper.show_hover, { "[REMOVE]" })
end

T["apply_suggestion.apply_to_first_word"] = function()
  Mock.values.buffer_helper.column_nr = 15

  local buf_nr = Mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  info1.hl_id = 51
  local info3 = get_info3(buf_nr)
  info3.hl_id = 52

  Cmd.all_diff_info = { vim.deepcopy(info1), vim.deepcopy(info3) }

  Cmd.apply_suggestion()

  local info3_updated = {
    alt_text = "yesterday.",
    buf_nr = 1,
    col_end = 37,
    col_start = 26,
    hl_group = "TaalIssue",
    line_nr = 1,
  }

  info3_updated.hl_id = 52
  eq(Mock.args_store.buffer_helper.add_hl_group, { info3_updated })

  info3_updated.hl_id = 101
  eq(Cmd.all_diff_info, { info3_updated })

  eq(
    Mock.args_store.buffer_helper.replace_text,
    { buf_nr, 1, info1.col_start, info1.col_end, info1.alt_text }
  )
end

T["apply_suggestion.apply_to_second_word"] = function()
  Mock.values.buffer_helper.column_nr = 30

  local buf_nr = Mock.buffhelp.current_buffer_nr()
  local info1 = get_info1(buf_nr)
  info1.hl_id = 51
  local info3 = get_info3(buf_nr)
  info3.hl_id = 52

  Cmd.all_diff_info = { vim.deepcopy(info1), vim.deepcopy(info3) }

  Cmd.apply_suggestion()

  eq(Cmd.all_diff_info, { info1 })

  -- add_hl_group should not have been called and this check value is not set
  eq(not Mock.args_store.buffer_helper.add_hl_group, true)

  -- delete_hl_group should have been called once
  eq(Mock.args_store.buffer_helper.delete_hl_group, { 1, 52 })

  eq(
    Mock.args_store.buffer_helper.replace_text,
    { buf_nr, 1, info3.col_start, info3.col_end, info3.alt_text }
  )
end

T["set_spelllang.normal_behaviour"] = function()
  local old_spelllang = vim.o.spelllang

  Cmd.set_spelllang()
  eq(vim.o.spelllang, "hu")
  eq(Mock.args_store.template_sender.send[2], Mock.templates.recognize_language)

  vim.o.spelllang = old_spelllang
end

return T
