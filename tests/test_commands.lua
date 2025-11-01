local Helpers = require("tests.helpers")
local tpl_grammar = require("kitt.templates.grammar")
local eq = MiniTest.expect.equality
local child, T = Helpers.new_child_with_set([[
  mock = require("tests.mock")
  cmd = require("kitt.commands")
  cmd.setup(mock.buffhelp, mock.post)
]])

T["improve_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()

  child.lua("cmd.improve_grammar()")

  eq(child.lua_get("mock.check.template"), tpl_grammar)
  eq(child.lua_get("mock.check.select_called"), true)

  local scratch_buf = child.lua_get("mock.values.scratch_buf")

  eq(child.lua_get("cmd.diff_info"), {
    {
      alt_text = "brighter",
      buf_nr = buf,
      col_end = 23,
      col_start = 12,
      extmark_id = 42,
      hl_group = "KittIssue",
      line_nr = 1,
    },
    {
      alt_text = "more bright",
      buf_nr = scratch_buf,
      col_end = 20,
      col_start = 12,
      extmark_id = 42,
      hl_group = "KittImprovement",
      line_nr = 1,
    },
    {
      alt_text = "yesterday.",
      buf_nr = buf,
      col_end = 40,
      col_start = 29,
      extmark_id = 42,
      hl_group = "KittIssue",
      line_nr = 1,
    },
    {
      alt_text = "yesterdate.",
      buf_nr = scratch_buf,
      col_end = 36,
      col_start = 26,
      extmark_id = 42,
      hl_group = "KittImprovement",
      line_nr = 1,
    },
  })
end

T["suggest_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()
  child.lua("cmd.suggest_grammar()")
  eq(child.lua_get("cmd.diff_info"), {
    {
      buf_nr = buf,
      line_nr = 1,
      col_start = 12,
      col_end = 23,
      hl_group = "KittIssue",
      alt_text = "brighter",
      extmark_id = 42,
    },
    {
      buf_nr = buf,
      line_nr = 1,
      col_start = 29,
      col_end = 40,
      hl_group = "KittIssue",
      alt_text = "yesterday.",
      extmark_id = 42,
    },
  })
end

return T
