local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local differ = require("kitt.diff")

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
    { { a_start = 1, a_end = 4, a_text = "abc", b_start = 1, b_end = 4, b_text = "xbc" } }
  )
  eq(
    differ.diff("abc def", "xbc def"),
    { { a_start = 1, a_end = 4, a_text = "abc", b_start = 1, b_end = 4, b_text = "xbc" } }
  )
  eq(
    differ.diff("abc def", "abc xef"),
    { { a_start = 5, a_end = 8, a_text = "def", b_start = 5, b_end = 8, b_text = "xef" } }
  )

  eq(differ.diff("abc def ghi", "xbc xef xhi"), {
    {
      a_start = 1,
      a_end = 12,
      a_text = "abc def ghi",
      b_start = 1,
      b_end = 12,
      b_text = "xbc xef xhi",
    },
  })

  eq(differ.diff("abc def ghi", "xbc def xhi"), {
    { a_start = 1, a_end = 4, a_text = "abc", b_start = 1, b_end = 4, b_text = "xbc" },
    { a_start = 9, a_end = 12, a_text = "ghi", b_start = 9, b_end = 12, b_text = "xhi" },
  })
end

return T
