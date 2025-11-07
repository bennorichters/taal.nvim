local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local differ = require("taal.diff")

-- TODO: test for empty texts

local T = new_set()

T["diff"] = new_set()

T["diff"]["equal"] = function()
  eq(differ.diff("abc", "abc"), {})
  eq(differ.diff(" abc", " abc"), {})
  eq(differ.diff("  abc", "  abc"), {})
  eq(differ.diff("abc ", "abc "), {})
  eq(differ.diff("abc  ", "abc  "), {})
  eq(differ.diff(" abc ", " abc "), {})
  eq(differ.diff("  abc  ", "  abc  "), {})

  eq(differ.diff("abc def", "abc def"), {})
  eq(differ.diff("abc  def", "abc  def"), {})
  eq(differ.diff("  abc  def  ", "  abc  def  "), {})
end

T["diff"]["changes"] = function()
  eq(
    differ.diff("abc", "xbc"),
    { { a_start = 0, a_end = 3, a_text = "abc", b_start = 0, b_end = 3, b_text = "xbc" } }
  )
  eq(
    differ.diff("abc def", "xbc def"),
    { { a_start = 0, a_end = 3, a_text = "abc", b_start = 0, b_end = 3, b_text = "xbc" } }
  )
  eq(
    differ.diff("abc def", "abc xef"),
    { { a_start = 4, a_end = 7, a_text = "def", b_start = 4, b_end = 7, b_text = "xef" } }
  )

  eq(differ.diff("abc def ghi", "xbc xef xhi"), {
    {
      a_start = 0,
      a_end = 11,
      a_text = "abc def ghi",
      b_start = 0,
      b_end = 11,
      b_text = "xbc xef xhi",
    },
  })

  eq(differ.diff("abc def ghi", "xbc def xhi"), {
    { a_start = 0, a_end = 3, a_text = "abc", b_start = 0, b_end = 3, b_text = "xbc" },
    { a_start = 8, a_end = 11, a_text = "ghi", b_start = 8, b_end = 11, b_text = "xhi" },
  })
end

T["diff"]["tbd"] = function()
  local locs = differ.diff("x a b", "a y b")
  -- {1,1,0,0}, {2,0,2,1}
  -- {1,1,0,0} -> x is replaced by nothing, i.e., deleted
  -- {2,0,2,1) -> before b (because Hunk size 0) y is inserted

  -- { a_start = 0, a_end = 1, a_text = "x", b_start = 0, b_end = 0, b_text = "" },
  -- { a_start = 3, a_end = 3, a_text = "", b_start = 2, b_end = 3, b_text = "y" },
end

return T
