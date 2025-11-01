local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local adapter = require("kitt.adapters.openai_responses")

local T = new_set()

T["adapters.openai_responses"] = new_set()

T["adapters.openai_responses"]["template"] = function()
end

T["adapters.openai_responses"]["template_stream"] = function()
end

T["adapters.openai_responses"]["post_headers"] = function()
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

T["adapters.openai_responses"]["parse_stream.no_content"] = function()
end

T["adapters.openai_responses"]["parse_stream.content_not_done"] = function()
end

T["adapters.openai_responses"]["parse_stream.empty_content_not_done"] = function()
end

T["adapters.openai_responses"]["parse_stream.content_done"] = function()
end

return T

