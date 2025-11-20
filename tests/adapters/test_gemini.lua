require("tests.helpers").enable_log()

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local adapter = require("taal.adapters.gemini")
adapter.url = "url"

local T = new_set()

T["adapters.gemini"] = new_set()

local template = {
  system = "a",
  examples = {
    { user = "b", assistant = "c" },
    { user = "d", assistant = "e" },
  },
  message = "%s",
}

local expected = {
  system_instruction = { parts = { { text = "a" } } },
  contents = {
    { role = "user", parts = { { text = "b" } } },
    { role = "model", parts = { { text = "c" } } },
    { role = "user", parts = { { text = "d" } } },
    { role = "model", parts = { { text = "e" } } },
    { role = "user", parts = { { text = "%s" } } },
  },
}

T["adapters.gemini"]["endpoint"] = function()
  eq(adapter:endpoint("m"), "url/v1beta/models/m:generateContent")
  eq(adapter:endpoint("m", true), "url/v1beta/models/m:streamGenerateContent?alt=sse")
end

T["adapters.gemini"]["post_headers"] = function()
  local env_var = "GEMINI_API_KEY"
  local old_env_api_key = os.getenv(env_var)
  vim.fn.setenv(env_var, "test_key")

  eq(adapter.post_headers(), {
    content_type = "application/json",
    x_goog_api_key = "test_key",
  })

  if old_env_api_key then
    vim.fn.setenv("OPENAI_API_KEY", old_env_api_key)
  end
end

T["adapters.gemini"]["template"] = function()
  eq(adapter.template(template), expected)
end

T["adapters.gemini"]["template.message_only"] = function()
  eq(
    adapter.template({ message = "a" }),
    { contents = { { role = "user", parts = { { text = "a" } } } } }
  )
end

T["adapters.gemini"]["template.multiple_message_placeholders"] = function()
  local template_mms = vim.deepcopy(template)
  local expected_mms = vim.deepcopy(expected)

  local mms = "%s 1 %s 2 %s 3"
  template_mms.message = mms
  expected_mms.contents[5].parts[1].text = "%s 1 %s 2 %s 3"
  eq(adapter.template(template_mms, "m"), expected_mms)
end

T["adapters.gemini"]["template_no_examples"] = function()
  eq(adapter.template({ system = "a", message = "b" }), {
    system_instruction = { parts = { { text = "a" } } },
    contents = { { role = "user", parts = { { text = "b" } } } },
  })
end

T["adapters.gemini"]["template_stream"] = function()
  local expected_stream = vim.deepcopy(expected)
  eq(adapter.template_stream(template, "m"), expected_stream)
end

T["adapters.gemini"]["parse"] = function()
  local json = { candidates = { { content = { parts = { { text = "a" } } } } } }
  eq(adapter.parse(json), "a")
end

T["adapters.gemini"]["parse.no_content"] = function()
  local done, content = adapter.parse_stream("")
  eq(done, false)
  eq(content, nil)
end

return T
