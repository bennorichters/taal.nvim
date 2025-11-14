local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local adapter = require("taal.adapters.openai_responses")

local T = new_set()

T["adapters.openai_responses"] = new_set()

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
  input = {
    { role = "system", content = "a" },
    { role = "user", content = "b" },
    { role = "assistant", content = "c" },
    { role = "user", content = "d" },
    { role = "assistant", content = "e" },
    { role = "user", content = "%s" },
  },
}

T["adapters.openai_responses"]["template"] = function()
  eq(adapter.template(template, "m"), expected)
end

T["adapters.openai_responses"]["template.multiple_message_stubs"] = function()
  local template_mms = vim.deepcopy(template)
  local expected_mms = vim.deepcopy(expected)

  local mms = "%s 1 %s 2 %s 3"
  template_mms.message = mms
  expected_mms.input[6].content = "%s 1 %s 2 %s 3"
  eq(adapter.template(template_mms, "m"), expected_mms)
end

T["adapters.openai_responses"]["template_stream"] = function()
  local expected_stream = vim.deepcopy(expected)
  expected_stream.stream = true
  eq(adapter.template_stream(template, "m"), expected_stream)
end

T["adapters.openai_responses"]["post_headers"] = function()
  local old_env_api_key = os.getenv("OPENAI_API_KEY")
  vim.fn.setenv("OPENAI_API_KEY", "test_key")

  eq(adapter.post_headers(), {
    headers = {
      content_type = "application/json",
      authorization = "Bearer " .. "test_key",
    },
  })

  if old_env_api_key then
    vim.fn.setenv("OPENAI_API_KEY", old_env_api_key)
  end
end

T["adapters.openai_responses"]["parse"] = function()
  local p = adapter.parse

  eq(
    adapter.parse({
      output = {
        { type = "reasoning" },
        {
          type = "message",
          content = {
            { type = "output_text", text = "42" },
          },
        },
      },
    }),
    "42"
  )
end

T["adapters.openai_responses"]["parse_stream"] = function()
  local p = adapter.parse_stream

  eq({ p(nil) }, { false, nil })
  eq({ p("") }, { false, nil })
  eq({ p("data: [DONE]") }, { false, nil })
  eq({ p("[DONE]") }, { false, nil })
  eq({ p("data: [READY]") }, { false, nil })
  eq({ p('data: {"choices":[{"delta":{"content":"abc"}}]}') }, { false, nil })
  eq({ p('data: {"choices":[{"delta":{"content":"abc"}}]') }, { false, nil })

  eq({ p('data: {"type":"response.output_text.delta","delta":"abc"}') }, { false, "abc" })
  eq({ p('data: {"type":"response.output_text.done"}') }, { true, nil })
end

return T
