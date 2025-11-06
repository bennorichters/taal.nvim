local function split_into_words(text)
  local prev_whitespace = true
  local index = 0

  local words = {}
  local starts = {}
  for char in string.gmatch(text .. " ", ".") do
    if string.match(char, "%s") then
      if not prev_whitespace then
        table.insert(words, string.sub(text, starts[#starts] + 1, index))
      end

      prev_whitespace = true
    elseif prev_whitespace then
      prev_whitespace = false
      table.insert(starts, index)
    end

    index = index + 1
  end

  return table.concat(words, "\n"), starts
end

local function diff_boundaries(starts, start_first, start_last, length)
  local diff_start = starts[start_first]
  local last_start = start_first + start_last
  local diff_end = last_start <= #starts and (starts[last_start] - 1) or length

  return diff_start, diff_end
end

local M = {}

---Computes a word-by-word diff between two texts.
---@param a string The first text to compare
---@param b string The second text to compare
---@return table<integer, {a_start: integer, a_end: integer, a_text: string, b_start: integer, b_end: integer, b_text: string}> result A list of diff regions, where each region contains start/end positions (0-indexed) and text content for both input strings
M.diff = function(a, b)
  local a_words, a_starts = split_into_words(a)
  local b_words, b_starts = split_into_words(b)

  local indices = vim.diff(a_words, b_words, { result_type = "indices" })

  local result = {}
  if type(indices) == "table" then
    for _, start_index in ipairs(indices) do
      local a_start, a_end = diff_boundaries(a_starts, start_index[1], start_index[2], #a_words)
      local b_start, b_end = diff_boundaries(b_starts, start_index[3], start_index[4], #b_words)

      table.insert(result, {
        a_start = a_start,
        a_end = a_end,
        a_text = string.sub(a, a_start + 1, a_end),
        b_start = b_start,
        b_end = b_end,
        b_text = string.sub(b, b_start + 1, b_end),
      })
    end
  end

  return result
end

return M
