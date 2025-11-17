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

T["buffer_helper.current_column_nr"] = function()
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "abc" })
  child.type_keys("l")

  local column_nr = child.lua_get("h.current_column_nr()")
  eq(column_nr, 2)
end

T["buffer_helper.add_hl_group"] = function()
  local ns = child.lua_get("h.namespace_hl")

  child.api.nvim_buf_set_lines(0, 0, -1, true, { "abcdefghijkl" })
  local id = child.lua_get([[h.add_hl_group({
    buf_nr = 0,
    line_nr = 1,
    col_start = 1,
    col_end = 3,
    hl_group = "TaalIssue"
  })]])

  local mark = child.api.nvim_buf_get_extmark_by_id(0, ns, id, {})

  eq(mark[1], 0)
  eq(mark[2], 1)
end

T["buffer_helper.delete_hl_group"] = function()
  local ns = child.lua_get("h.namespace_hl")

  child.api.nvim_buf_set_lines(0, 0, -1, true, { "abcdefghijkl" })
  local id = child.lua_get([[h.add_hl_group({
    buf_nr = 0,
    line_nr = 1,
    col_start = 1,
    col_end = 3,
    hl_group = "TaalIssue"
  })]])

  child.lua("h.delete_hl_group(0, " .. id .. ")")

  local mark = child.api.nvim_buf_get_extmark_by_id(0, ns, id, {})

  eq(mark, {})
end

return T
