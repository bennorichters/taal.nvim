local Helpers = require("tests.helpers")
local eq = MiniTest.expect.equality
local user_text = "The moon is more bright then yesterdate."
local ai_text = "The moon is brighter then yesterday."
local child, T = Helpers.new_child_with_set(string.format(
  [[
  local user_text = "%s"
  local ai_text = "%s"

  local buffhelp = {
    add_hl_group = function(info) return 42 end,
    text_under_cursor = function() return user_text end,
  }

  local tempsend = {
    stream = function(_template, callback)
      -- local old_select = vim.ui.select
      -- vim.ui.select = function()
      -- end
      -- callback(42, ai_text)
      -- vim.ui.select = old_select
    end,
    send = function(template, data) return ai_text end,
  }

  cmd = require("kitt.commands")
  cmd.setup(buffhelp, tempsend)
]],
  user_text,
  ai_text
))

T["ai_improve_grammar"] = function()
  local ui_select = false

  child.lua("cmd.ai_improve_grammar()")
  -- eq(ui_select, true)
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
