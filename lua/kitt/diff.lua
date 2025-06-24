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

local M = {}

M.change_location = function(original, suggestion)
  local org_words, org_starts = splitIntoWords(original)
  local sug_words, _ = splitIntoWords(suggestion)

  local indices = vim.diff(org_words, sug_words, { result_type = "indices" })

  local result = {}
  if type(indices) == "table" then
    for _, start_index in ipairs(indices) do
      local change_start = org_starts[start_index[1]]
      local index_end = start_index[1] + start_index[2]
      local change_end = index_end <= #org_starts and (org_starts[index_end] - 1) or #org_words
      table.insert(result, { change_start, change_end })
    end
  end

  return result
end

return M
