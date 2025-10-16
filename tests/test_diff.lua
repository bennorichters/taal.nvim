local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local differ = require("kitt.diff")

local T = new_set()

T["diff"] = new_set()

T["diff"]["equal"] = function()
  eq(differ.change_location("abc", "abc"), {})
  eq(differ.change_location(" abc", " abc"), {})
  eq(differ.change_location("  abc", "  abc"), {})
  eq(differ.change_location("abc ", "abc "), {})
  eq(differ.change_location("abc  ", "abc  "), {})
  eq(differ.change_location(" abc ", " abc "), {})
  eq(differ.change_location("  abc  ", "  abc  "), {})

  eq(differ.change_location("abc def", "abc def"), {})
  eq(differ.change_location("abc  def", "abc  def"), {})
  eq(differ.change_location("  abc  def  ", "  abc  def  "), {})
end

T["diff"]["changes"] = function()
  eq(differ.change_location("abc", "xbc"), { { left = 1, right = 4, improvement = "xbc" } })
  eq(differ.change_location("abc def", "xbc def"), { { left = 1, right = 4, improvement = "xbc" } })
  eq(differ.change_location("abc def", "abc xef"), { { left = 5, right = 8, improvement = "xef" } })

  eq(differ.change_location("abc def ghi", "xbc xef xhi"), {
    { left = 1, right = 12, improvement = "xbc xef xhi" },
  })

  eq(differ.change_location("abc def ghi", "xbc def xhi"), {
    { left = 1, right = 4, improvement = "xbc" },
    { left = 9, right = 12, improvement = "xhi" },
  })
end

return T
