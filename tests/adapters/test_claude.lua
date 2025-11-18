require("tests.helpers").enable_log()

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local adapter = require("taal.adapters.claude")

local T = new_set()

T["adapters.claude"] = new_set()

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
  max_tokens = 1024,
  system = "a",
  messages = {
    { role = "user", content = "b" },
    { role = "assistant", content = "c" },
    { role = "user", content = "d" },
    { role = "assistant", content = "e" },
    { role = "user", content = "%s" },
  },
}

T["adapters.claude"]["template"] = function()
  eq(adapter.template(template, "m"), expected)
end

T["adapters.claude"]["template.multiple_message_placeholders"] = function()
  local template_mms = vim.deepcopy(template)
  local expected_mms = vim.deepcopy(expected)

  local mms = "%s 1 %s 2 %s 3"
  template_mms.message = mms
  expected_mms.messages[5].content = "%s 1 %s 2 %s 3"
  eq(adapter.template(template_mms, "m"), expected_mms)
end

T["adapters.claude"]["template_no_examples"] = function()
  eq(adapter.template({ system = "a", message = "%s" }, "m"), {
    model = "m",
    max_tokens = 1024,
    system = "a",
    messages = {
      { role = "user", content = "%s" },
    },
  })
end

T["adapters.claude"]["template_only_message"] = function()
  eq(adapter.template({ message = "%s" }, "m"), {
    model = "m",
    max_tokens = 1024,
    messages = {
      { role = "user", content = "%s" },
    },
  })
end

T["adapters.claude"]["template_stream"] = function()
  local expected_stream = vim.deepcopy(expected)
  expected_stream.stream = true
  eq(adapter.template_stream(template, "m"), expected_stream)
end

T["adapters.claude"]["post_headers"] = function()
  local env_var = "CLAUDE_API_KEY"
  local old_env_api_key = os.getenv(env_var)
  vim.fn.setenv(env_var, "test_key")

  eq(adapter.post_headers(), {
    headers = {
      content_type = "application/json",
      anthropic_version = "2023-06-01",
      x_api_key = "test_key",
    },
  })

  if old_env_api_key then
    vim.fn.setenv(env_var, old_env_api_key)
  end
end

T["adapters.claude"]["parse"] = function()
  local response = [[
    {
      "type": "message",
      "role": "assistant",
      "content": [
        {
          "type": "text",
          "text": "42"
        }
      ]
    }]]

  local json = vim.fn.json_decode(response)
  eq(adapter.parse(json), "42")
end

T["adapters.claude"]["parse_stream.no_content"] = function()
  local done, content = adapter.parse_stream("")
  eq(done, false)
  eq(content, nil)
end

T["adapters.claude"]["parse_stream"] = function()
  local done, content = adapter.parse_stream([[data: 
  {
    "type":"content_block_delta",
    "delta":{
      "type":"text_delta",
      "text":"42"
    }
  }
  ]])

  eq(done, false)
  eq(content, "42")
end

return T
