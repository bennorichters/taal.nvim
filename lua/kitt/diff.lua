local function startOfWord(text, word_index)
  local prev_whitespace = true
  local word_count = 1
  local result = 0
  for char in string.gmatch(text, ".") do
    result = result + 1
    if string.match(char, "%s") and not prev_whitespace then
      prev_whitespace = true
      word_count = word_count + 1
    elseif prev_whitespace and word_count == word_index then
      return result
    else
      prev_whitespace = false
    end
  end

  return nil
end

local r = startOfWord("hello world, this is me", 3)
print(r)
