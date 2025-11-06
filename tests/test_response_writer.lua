local Helpers = require("tests.helpers")
local eq = MiniTest.expect.equality
local child, T = Helpers.new_child_with_set([[
  rwf = require("taal.response_writer")
  rw = rwf:new()
  rw:create_scratch_buffer()
]])

local get_lines = function(buf)
  return child.api.nvim_buf_get_lines(buf, 0, -1, true)
end

T["response_writer.write"] = function()
  local buf = child.lua_get("rw.bufnr")

  child.lua("rw:write('abc')")
  eq(get_lines(buf), { "abc" })

  child.lua("rw:write('def')")
  eq(get_lines(buf), { "abcdef" })

  child.lua("rw:write('g\\nhi')")
  eq(get_lines(buf), { "abcdefg", "hi" })
end

return T
