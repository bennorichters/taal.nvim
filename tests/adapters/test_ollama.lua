local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local adapter = require("kitt.adapters.ollama")

local T = new_set()

T["adapters.ollama"] = new_set()

local template = {
  system = "a",
  examples = {
    { user = "b", assistant = "c" },
    { user = "d", assistant = "e" },
  },
}

local expected = {
  model = "gemma3",
  input = {
    { role = "system", content = "a" },
    { role = "user", content = "b" },
    { role = "assistant", content = "c" },
    { role = "user", content = "d" },
    { role = "assistant", content = "e" },
  },
}

T["adapters.ollama"]["template"] = function()
  eq(adapter.template(template), expected)
end

T["adapters.ollama"]["template_stream"] = function()
  local expected_stream = vim.deepcopy(expected)
  expected_stream.stream = true
  eq(adapter.template_stream(template), expected_stream)
end

return T
