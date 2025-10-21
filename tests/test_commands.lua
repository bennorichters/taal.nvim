local Helpers = require("tests.helpers")
local eq = MiniTest.expect.equality

local user_text = "The moon is more bright then yesterdate."
local ai_text = "The moon is brighter then yesterday."
local child, T = Helpers.new_child_with_set(string.format(
  [[
  local buffhelp = {
    text_under_cursor = function() return "%s" end
  }

  local tempsend = {
    stream = function() end,
    send = function(templace, data) return "%s" end,
  }

  cmd = require("kitt.commands")
  cmd.setup(buffhelp, tempsend)
]],
  user_text,
  ai_text
))

local function contains_spell_bad_highlight(table, start, length)
  for i = 1, #table do
    if
      table[i].group == "SpellBad"
      and table[i].pos1[1] == 1
      and table[i].pos1[2] == start
      and table[i].pos1[3] == length
    then
      return true
    end
  end
  return false
end

T["ai_suggest_grammar"] = function()
  local buf = child.api.nvim_create_buf(true, true)
  child.api.nvim_buf_set_lines(buf, 0, -1, false, { user_text })

  child.lua("cmd.ai_suggest_grammar()")
  local highlights = child.fn.getmatches()

  eq(contains_spell_bad_highlight(highlights, 13, 11), true)
  eq(contains_spell_bad_highlight(highlights, 30, 11), true)
end

return T
