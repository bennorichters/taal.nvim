local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local format = require("taal.template_formatter")

local T = new_set()

T["formatter"] = new_set()

T["formatter"]["single_string_user_input"] = function()
  local template = {
    foo = "bar",
    fooz = "%s",
  }
  local user_input = "barz"

  local json = format(template, user_input)
  local result = vim.fn.json_decode(json)

  local expected = {
    foo = "bar",
    fooz = "barz",
  }
  eq(result, expected)
end

T["formatter"]["list_user_input"] = function()
  local template = {
    foo = "bar",
    fooz = "0 %s 1 %s 2",
  }
  local user_input = {"barx", "bary"}

  local json = format(template, user_input)
  local result = vim.fn.json_decode(json)

  local expected = {
    foo = "bar",
    fooz = "0 barx 1 bary 2",
  }
  eq(result, expected)
end

T["formatter"]["nil"] = function()
  local template = {
    foo = "bar",
    fooz = "0 %s 1 %s 2",
  }
  local user_input = nil

  local json = format(template, user_input)
  local result = vim.fn.json_decode(json)

  eq(result, template)
end

T["formatter"]["empty"] = function()
  local template = {
    foo = "bar",
    fooz = "0 %s 1",
  }
  local user_input = ""

  local json = format(template, user_input)
  local result = vim.fn.json_decode(json)

  local expected = {
    foo = "bar",
    fooz = "0  1",
  }
  eq(result, expected)
end

T["formatter"]["encoding"] = function()
  local template = {
    foo = "bar",
    fooz = "0 %s 1",
  }
  local user_input = '"fooz": "barz"'

  local json = format(template, user_input)
  local result = vim.fn.json_decode(json)

  local expected = {
    foo = "bar",
    fooz = "0 " .. user_input .. " 1",
  }
  eq(result, expected)
end

return T
