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
    headers = {
      content_type = "application/json",
      x_goog_api_key = "test_key",
    },
  })

  if old_env_api_key then
    vim.fn.setenv("OPENAI_API_KEY", old_env_api_key)
  end
end

T["adapters.gemini"]["template"] = function()
  eq(adapter.template(template), expected)
end

T["adapters.gemini"]["template_no_examples"] = function() end

T["adapters.gemini"]["template_stream"] = function() end

T["adapters.gemini"]["parse"] = function()
  local json = { candidates = { { content = { parts = { { text = "a" } } } } } }
  eq(adapter.parse(json), "a")
end

T["adapters.gemini"]["parse.no_content"] = function() end

T["adapters.gemini"]["parse.content_not_done"] = function() end

T["adapters.gemini"]["parse.empty_content_not_done"] = function() end

T["adapters.gemini"]["parse.content_done"] = function() end

return T
