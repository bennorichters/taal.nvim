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
  url = "url",
  endpoint = function()
    return "endpoint"
  end,
  post_headers = function()
    return { foo = "bar" }
  end,
  template = function()
    return '{fooz = "barz"}'
  end,
  template_stream = function()
    return '{fooz = "barz_stream"}'
  end,
  parse = function(_)
    return "42"
  end,
  parse_stream = function()
    return true, "43"
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

  local ts = require("taal.template_sender")(post, nil, 10)
  eq(ts.send({ adapter = adapter_mock, model = "m" }), "42")
  eq(post_called, true)
end

T["template_sender"]["stream"] = function()
  local function post(endpoint, opts)
    eq(endpoint, "endpoint")
    eq(tablelength(opts), 4)
    eq(opts.headers, { foo = "bar" })
    eq(opts.raw, { "--tcp-nodelay", "--no-buffer" })
    local body = vim.fn.json_decode(opts.body)
    eq(body, adapter_mock.template_stream())

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

  local ts = require("taal.template_sender")(post, ResponseWriterMock, 10)
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

  local ts = require("taal.template_sender")(post, ResponseWriterMock, 10)
  ts.stream({ adapter = adapter_mock, model = "m" })

  vim.schedule_wrap = orig_schedule_wrap
end

T["template_sender"]["stream.done_with_delta"] = function()
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

  local call_back_check
  local call_back = function()
    call_back_check = true
  end

  local check_write
  local ResponseWriterMockCheckWrite = {
    new = function()
      return {
        create_scratch_buffer = function() end,
        write = function(_, delta)
          check_write = delta
        end,
      }
    end,
  }

  local ts = require("taal.template_sender")(post, ResponseWriterMockCheckWrite, 10)
  ts.stream({ adapter = adapter_mock, model = "m" }, nil, nil, call_back)

  eq(check_write, "43")
  eq(call_back_check, true)

  vim.schedule_wrap = orig_schedule_wrap
end

T["template_sender"]["stream.user_input_list"] = function()
  local adapter_multiple_placeholders_stream = vim.deepcopy(adapter_mock)
  adapter_multiple_placeholders_stream.template_stream = function()
    return { foo = "0 %s 1 %s 2" }
  end

  local user_input = { "barx", "bary" }

  local function post(_, opts)
    local body = vim.fn.json_decode(opts.body)
    eq(body, { foo = "0 barx 1 bary 2" })
    return { status = 200, body = "{}" }
  end

  local orig_schedule_wrap = vim.schedule_wrap
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.schedule_wrap = function(fn)
    return function()
      fn()
    end
  end

  local ts = require("taal.template_sender")(post, ResponseWriterMock, 10)
  ts.stream({ adapter = adapter_multiple_placeholders_stream, model = "m" }, nil, user_input)

  vim.schedule_wrap = orig_schedule_wrap
end

return T
