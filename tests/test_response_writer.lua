local Helpers = require("tests.helpers")
local eq = MiniTest.expect.equality
local child, T = Helpers.new_child_with_set([[
  RW = require("taal.response_writer")
  w = RW:new()
  w:create_scratch_buffer()
]])

T["response_writer.write"] = function()
  local buf = child.lua_get("w.bufnr")

  child.lua("w:write('abc')")
  eq(Helpers.get_lines(child, buf), { "abc" })

  child.lua("w:write('def')")
  eq(Helpers.get_lines(child, buf), { "abcdef" })

  child.lua("w:write('g\\nhi')")
  eq(Helpers.get_lines(child, buf), { "abcdefg", "hi" })
end

return T
