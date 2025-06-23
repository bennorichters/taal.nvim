local function wordsRange(text, index_word_start, index_word_end)
  local prev_whitespace = true
  local word_count = 1
  local result = {}
  local index = 0
  local to_find = index_word_start
  for char in string.gmatch(text, ".") do
    index = index + 1
    if string.match(char, "%s") and not prev_whitespace then
      prev_whitespace = true
      word_count = word_count + 1
    elseif prev_whitespace and word_count == to_find then
      if to_find == index_word_end + 1 then
        result["end"] = index - 1
        return result
      end

      result["start"] = index
      to_find = index_word_end + 1
    else
      prev_whitespace = false
    end
  end

  if result["start"] then
    result["end"] = #text + 1
    return result
  end

  return nil
end

-- local function aap(original, suggestion)
--   local split_original = string.gsub(original, "%s", "\n") .. "\n"
--   local split_suggestion = string.gsub(suggestion, "%s", "\n") .. "\n"
--
--   local indices = vim.diff(split_original, split_suggestion, { result_type = "indices" })
-- end
--
-- aap()
-- wordsRange()

local r = wordsRange("abc def ghi jkl", 2, 4)
print(vim.inspect(r))
