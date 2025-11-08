local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local differ = require("taal.diff")

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

T["diff"]["deleting_words"] = function()
  eq(differ.diff("x a b", "a y b"), {
    { a_start = 0, a_end = 1, a_text = "x", b_start = 0, b_end = 0, b_text = "" },
    { a_start = 0, a_end = 0, a_text = "", b_start = 2, b_end = 3, b_text = "y" },
  })
end

T["diff"]["empty_texts"] = function()
  eq(differ.diff("", ""), {})
  eq(differ.diff("", "a b c"), {
    { a_start = 0, a_end = 0, a_text = "", b_start = 0, b_end = 5, b_text = "a b c" },
  })
end

return T
