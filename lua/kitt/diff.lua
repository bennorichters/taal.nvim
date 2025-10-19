local function split_into_words(text)
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

local function diff_boundaries(starts, start_first, start_last, length)
  local diff_start = starts[start_first]
  local last_start = start_first + start_last
  local diff_end = last_start <= #starts and (starts[last_start] - 1) or (length + 1)

  return diff_start, diff_end
end

local M = {}

M.diff = function(a, b)
  local words_a, starts_a = split_into_words(a)
  local words_b, starts_b = split_into_words(b)

  local indices = vim.diff(words_a, words_b, { result_type = "indices" })

  local result = {}
  if type(indices) == "table" then
    for _, start_index in ipairs(indices) do
      local a_start, a_end = diff_boundaries(starts_a, start_index[1], start_index[2], #words_a)
      local b_start, b_end = diff_boundaries(starts_b, start_index[3], start_index[4], #words_b)

      table.insert(result, {
        a_start = a_start,
        a_end = a_end,
        b_word = string.sub(b, b_start, b_end - 1),
      })
    end
  end

  return result
end

return M
