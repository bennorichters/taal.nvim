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

local function aap(original, suggestion)
  local org_words, org_starts = splitIntoWords(original)
  local sug_words, sug_starts = splitIntoWords(suggestion)

  local indices = vim.diff(org_words, sug_words, { result_type = "indices" })

  return indices
end

local i = aap("aap noot mies wim zus", "aap noot zus wim jet")
print(vim.inspect(i))
