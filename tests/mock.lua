local default_values = {
  buffer_helper = {
    buffer_nr = 1,
    column_nr = 1,
    hl_id = 100,
    line_nr = 1,
    scratch_buf = 42,
    user_text = "The moon is more bright then yesterdate.",
    visual_selection = "foo bar",
  },
  template_sender = {
    ai_text = "The moon is brighter then yesterday.",
    interact = "interact_response",
    lang_code = "hu",
  },
}

local M = {}

M.adapter_model = {
  improve_grammar = {
    adapter = "",
    model = "",
  },
  suggest_grammar = {
    adapter = "",
    model = "",
  },
  set_spelllang = {
    adapter = "",
    model = "",
  },
  interact = {
    adapter = "",
    model = "",
  },
}

M.templates = {
  grammar = "grammar",
  interact = "interact",
  recognize_language = "recognize_language",
}

M.reset = function()
  M.values = vim.deepcopy(default_values)
  M.args_store = {}
end

local function add_args_to_store(group_name, key, ...)
  M.args_store[group_name] = M.args_store[group_name] or {}
  M.args_store[group_name][key] = M.args_store[group_name][key] or {}

  for i = 1, select("#", ...) do
    local value = select(i, ...)
    table.insert(M.args_store[group_name][key], vim.deepcopy(value))
  end
end

local args_store_super = function(name, mock)
  return setmetatable({}, {
    __index = function(_, key)
      return function(...)
        add_args_to_store(name, key, ...)
        if mock[key] then
          return mock[key](...)
        end
      end
    end,
  })
end

local buffer_helper_mock = {
  current_buffer_nr = function()
    return M.values.buffer_helper.buffer_nr
  end,
  current_column_nr = function()
    return M.values.buffer_helper.column_nr
  end,
  current_line_nr = function()
    return M.values.buffer_helper.line_nr
  end,
  add_hl_group = function()
    M.values.buffer_helper.hl_id = M.values.buffer_helper.hl_id + 1
    return M.values.buffer_helper.hl_id
  end,
  text_under_cursor = function()
    return M.values.buffer_helper.user_text
  end,
  visual_selection = function()
    return M.values.buffer_helper.visual_selection
  end,
}

local template_sender_mock = {
  stream = function(_adapter_model, _template, _user_input, callback)
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function()
      M.args_store.template_sender_stream_select_called = true
    end

    if callback then
      callback(M.values.buffer_helper.scratch_buf, M.values.template_sender.ai_text)
    end
  end,
  send = function(_adapter_model, template, _user_input)
    if template == M.templates.grammar then
      return M.values.template_sender.ai_text
    elseif template == M.templates.recognize_language then
      return M.values.template_sender.lang_code
    end

    error("unexpected template")
  end,
}

M.buffhelp = args_store_super("buffer_helper", buffer_helper_mock)

M.template_sender = args_store_super("template_sender", template_sender_mock)

M.reset()

return M
