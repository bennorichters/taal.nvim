local function splitIntoWords(text)
  local prev_whitespace = true
  local index = 0

  local words = {}
  local starts = {}
  for char in string.gmatch(text .. " ", ".") do
    index = index + 1

    if string.match(char, "%s") then
      if not prev_whitespace then
        table.insert(words, string.sub(text, starts[#starts], index - 1))
      end

      prev_whitespace = true
    elseif prev_whitespace then
      prev_whitespace = false
      table.insert(starts, index)
    end
  end

  return table.concat(words, "\n"), starts
end

local function change_boundaries(lefts, left_index, length)
  local change_left = lefts[left_index[1]]
  local last_left = left_index[1] + left_index[2]
  local change_right = last_left <= #lefts and (lefts[last_left] - 1) or length

  return change_left, change_right
end

local M = {}

M.change_location = function(text1, text2)
  local words1, lefts1 = splitIntoWords(text1)
  local words2, _ = splitIntoWords(text2)

  local indices = vim.diff(words1, words2, { result_type = "indices" })

  local result = {}
  if type(indices) == "table" then
    for _, left_index in ipairs(indices) do
      local left1, right1 = change_boundaries(lefts1, left_index, #words1)

      table.insert(result, {
        left = left1,
        right = right1,
      })
    end
  end

  return result
end

return M
