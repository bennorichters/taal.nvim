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

T["adapters.ollama"]["parse"] = function()
  local response = [[
    {
      "message": {
        "role": "assistant",
        "content": "42"
      },
      "done": true
    }]]

  local json = vim.fn.json_decode(response)
  eq(adapter.parse(json), "42")
end

T["adapters.ollama"]["parse.no_content"] = function()
  local done, content = adapter.parse_stream("")
  eq(done, false)
  eq(content, nil)
end

T["adapters.ollama"]["parse.content_not_done"] = function()
  local stream_data = [[
    {
      "message": {
          "role": "assistant",
          "content": "42"
      },
      "done": false
    }]]

  local done, content = adapter.parse_stream(stream_data)
  eq(done, false)
  eq(content, "42")
end

T["adapters.ollama"]["parse.empty_content_not_done"] = function()
  local stream_data = [[
    {
      "message": {
          "role": "assistant",
          "content": ""
      },
      "done": false
    }]]

  local done, content = adapter.parse_stream(stream_data)
  eq(done, false)
  eq(content, "")
end

T["adapters.ollama"]["parse.content_done"] = function()
  local stream_data = [[
    {
      "message": {
          "role": "assistant",
          "content": "."
      },
      "done": true
    }]]

  local done, content = adapter.parse_stream(stream_data)
  eq(done, true)
  eq(content, ".")
end

return T
