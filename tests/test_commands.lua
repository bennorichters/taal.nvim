local Helpers = require("tests.helpers")
local tpl_grammar = require("kitt.templates.grammar")
local eq = MiniTest.expect.equality
local user_text = "The moon is more bright then yesterdate."
local ai_text = "The moon is brighter then yesterday."
local scratch_buf = 42
local child, T = Helpers.new_child_with_set(string.format(
  [[
  local user_text = "%s"
  local ai_text = "%s"
  local scratch_buf = %s

  check = {
    select_called = false,
    template = nill,
  }

  local buffhelp = {
    add_hl_group = function(info) return scratch_buf end,
    text_under_cursor = function() return user_text end,
  }

  local tempsend = {
    stream = function(template, callback)
      check.template = template
      vim.ui.select = function() check.select_called = true end
      callback(scratch_buf, ai_text)
    end,
    send = function(template, data) return ai_text end,
  }

  cmd = require("kitt.commands")
  cmd.setup(buffhelp, tempsend)
]],
  user_text,
  ai_text,
  scratch_buf
))

T["ai_improve_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()

  child.lua("cmd.ai_improve_grammar()")
  eq(child.lua_get("check.template"), tpl_grammar)
  eq(child.lua_get("check.select_called"), true)

  eq(
    child.lua_get("cmd.diff_info"),
    {
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
    }
  )
end

T["ai_suggest_grammar"] = function()
  local buf = vim.api.nvim_get_current_buf()
  child.lua("cmd.ai_suggest_grammar()")
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
