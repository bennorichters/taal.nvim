require("tests.helpers").enable_log()

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do
    count = count + 1
  end
  return count
end

local adapter_mock = {
  endpoint = "endpoint",
  post_headers = function()
    return { headers = { foo = "bar" } }
  end,
  template = function(_)
    return '{fooz = "barz"}'
  end,
  template_stream = function(_)
    return '{fooz = "barz"}'
  end,
  parse = function(_)
    return "42"
  end,
  parse_stream = function(_)
    return "42"
  end,
}

local ResponseWriterMock = {
  new = function()
    return {
      create_scratch_buffer = function() end,
      write = function() end,
    }
  end,
}

local T = new_set()

T["template_sender"] = new_set()

T["template_sender"]["send"] = function()
  local post_called
  local function post(endpoint, opts)
    post_called = true
    eq(endpoint, "endpoint")
    eq(opts, {
      headers = { foo = "bar" },
      timeout = 10,
      body = '"{fooz = \\"barz\\"}"',
    })

    return { status = 200, body = "{}" }
  end

  local ts = require("kitt.template_sender")(post, nil, 10)
  eq(ts.send({ adapter = adapter_mock, model = "m" }), "42")
  eq(post_called, true)
end

T["template_sender"]["stream"] = function()
  local function post(endpoint, opts)
    eq(endpoint, "endpoint")
    eq(tablelength(opts), 4)
    eq(opts.headers, { foo = "bar" })
    eq(opts.raw, { "--tcp-nodelay", "--no-buffer" })
    eq(opts.body, '"{fooz = \\"barz\\"}"')

    opts.stream()

    return { status = 200, body = "{}" }
  end

  local call_back_check
  local call_back = function()
    call_back_check = true
  end

  local orig_schedule_wrap = vim.schedule_wrap
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.schedule_wrap = function(fn)
    return function()
      fn()
    end
  end

  local ts = require("kitt.template_sender")(post, ResponseWriterMock, 10)
  ts.stream({ adapter = adapter_mock, model = "m" }, nil, nil, call_back)

  eq(call_back_check, true)
  vim.schedule_wrap = orig_schedule_wrap
end

T["template_sender"]["stream.no_call_back_is_fine"] = function()
  local function post(_, opts)
    opts.stream()
    return { status = 200, body = "{}" }
  end

  local orig_schedule_wrap = vim.schedule_wrap
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.schedule_wrap = function(fn)
    return function()
      fn()
    end
  end

  local ts = require("kitt.template_sender")(post, ResponseWriterMock, 10)
  ts.stream({ adapter = adapter_mock, model = "m" })

  vim.schedule_wrap = orig_schedule_wrap
end

return T
