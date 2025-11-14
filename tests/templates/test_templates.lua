local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local format = require("taal.template_formatter")
local grammar = require("taal.templates.grammar")
local interact = require("taal.templates.interact_with_content")
local languague = require("taal.templates.recognize_language")

local T = new_set()

T["templates"] = new_set()

T["templates"]["grammar"] = function()
  local json = format(grammar, "foo")
  local message = vim.fn.json_decode(json).message
  eq(message, "foo")
end

T["templates"]["interact"] = function()
  local json = format(interact, { "foo", "bar" })
  local message = vim.fn.json_decode(json).message
  eq(message, "foo\n\nbar")
end

T["templates"]["language"] = function()
  local json = format(languague, "foo")
  local message = vim.fn.json_decode(json).message
  eq(message, "foo")
end

return T
