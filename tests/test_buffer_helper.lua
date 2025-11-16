local Helpers = require("tests.helpers")
local eq = MiniTest.expect.equality
local child, T = Helpers.new_child_with_set([[
  h = require("taal.buffer_helper")
  h.setup()
]])

local get_lines = function(buf)
  return child.api.nvim_buf_get_lines(buf, 0, -1, true)
end

T["buffer_helper.current_buffer_nr"] = function()
  local buf_nr = child.lua_get("h.current_buffer_nr()")
  child.api.nvim_buf_set_lines(buf_nr, 0, -1, true, { "a", "b", "c" })

  eq({ "a", "b", "c" }, get_lines(0))
end

T["buffer_helper.current_line_nr"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "a", "b", "c" })
  child.type_keys("j")

  local line_nr = child.lua_get("h.current_line_nr()")
  eq(line_nr, 2)
end

return T
