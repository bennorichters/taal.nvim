require("tests.helpers").enable_log()

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local T = new_set()

T["template_sender"] = new_set()

T["template_sender"]["send"] = function()
  local check_endpoint
  local check_opts

  local adapter = {
    endpoint = "endpoint",
    post_headers = function()
      return { headers = { foo = "bar" } }
    end,
    template = function(_)
      return '{fooz = "barz"}'
    end,
    parse = function(_)
      return "42"
    end,
  }

  local function post(endpoint, opts)
    check_endpoint = endpoint
    check_opts = opts

    return { status = 200, body = "{}" }
  end

  local ts = require("kitt.template_sender")(adapter, post, 10)
  eq(ts.send(), "42")
  eq(check_endpoint, "endpoint")
  eq(check_opts, {
    headers = { foo = "bar" },
    timeout = 10,
    body = '"{fooz = \\"barz\\"}"',
  })
end

return T
