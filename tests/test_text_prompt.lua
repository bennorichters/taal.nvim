local Helpers = require("tests.helpers")
local eq = MiniTest.expect.equality
local child, T = Helpers.new_child_with_set([[
  prompt = require('taal.text_prompt').prompt
]])

local get_lines = function(buf)
  return child.api.nvim_buf_get_lines(buf, 0, -1, true)
end

T["prompt"] = function()
  local buf = child.api.nvim_create_buf(true, true)

  child.api.nvim_buf_set_lines(buf, 0, -1, false, { "a", "b", "c", "d", "e" })
  child.lua_notify("prompt(" .. buf .. ", 0, {'1', '2', '3'})")
  child.type_keys("1<CR>")
  eq(get_lines(buf), { "1", "2", "3", "b", "c", "d", "e" })
end

return T
