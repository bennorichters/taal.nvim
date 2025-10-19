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
    { { a_start = 1, a_end = 4, a_word = "abc", b_start = 1, b_end = 4, b_word = "xbc" } }
  )
  eq(
    differ.diff("abc def", "xbc def"),
    { { a_start = 1, a_end = 4, a_word = "abc", b_start = 1, b_end = 4, b_word = "xbc" } }
  )
  eq(
    differ.diff("abc def", "abc xef"),
    { { a_start = 5, a_end = 8, a_word = "def", b_start = 5, b_end = 8, b_word = "xef" } }
  )

  eq(differ.diff("abc def ghi", "xbc xef xhi"), {
    {
      a_start = 1,
      a_end = 12,
      a_word = "abc def ghi",
      b_start = 1,
      b_end = 12,
      b_word = "xbc xef xhi",
    },
  })

  eq(differ.diff("abc def ghi", "xbc def xhi"), {
    { a_start = 1, a_end = 4, a_word = "abc", b_start = 1, b_end = 4, b_word = "xbc" },
    { a_start = 9, a_end = 12, a_word = "ghi", b_start = 9, b_end = 12, b_word = "xhi" },
  })
end

return T
