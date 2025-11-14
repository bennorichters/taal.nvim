require("tests.helpers").enable_log()

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local adapter = require("taal.adapters.ollama")

local T = new_set()

T["adapters.ollama"] = new_set()

local template = {
  system = "a",
  examples = {
    { user = "b", assistant = "c" },
    { user = "d", assistant = "e" },
  },
  message = "%s",
}

local expected = {
  model = "m",
  messages = {
    { role = "system", content = "a" },
    { role = "user", content = "b" },
    { role = "assistant", content = "c" },
    { role = "user", content = "d" },
    { role = "assistant", content = "e" },
    { role = "user", content = "%s" },
  },
}

T["adapters.ollama"]["template"] = function()
  local expected_copy = vim.deepcopy(expected)
  expected_copy.stream = false
  eq(adapter.template(template, "m"), expected_copy)
end

T["adapters.ollama"]["template_no_examples"] = function()
  eq(adapter.template({ system = "a", message = "%s" }, "m"), {
    model = "m",
    stream = false,
    messages = {
      { role = "system", content = "a" },
      { role = "user", content = "%s" },
    },
  })
end

T["adapters.ollama"]["template_stream"] = function()
  local expected_stream = vim.deepcopy(expected)
  expected_stream.stream = true
  eq(adapter.template_stream(template, "m"), expected_stream)
end

T["adapters.ollama"]["post_headers"] = function()
  eq(adapter.post_headers(), { headers = { content_type = "application/json" } })
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
