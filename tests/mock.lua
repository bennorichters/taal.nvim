local tpl_grammar = require("taal.templates.grammar")
local tpl_interact = require("taal.templates.interact_with_content")
local tpl_lang = require("taal.templates.recognize_language")

local original_values = {
  ai_text = "The moon is brighter then yesterday.",
  user_text = "The moon is more bright then yesterdate.",
  lang_code = "hu",
  scratch_buf = 42,
  hl_id = 100,
}

local M = {}

M.reset = function()
  M.values = vim.deepcopy(original_values)
  M.check = {}
end

local function add_check_value(group_name, key, ...)
  M.check[group_name] = M.check[group_name] or {}
  M.check[group_name][key] = M.check[group_name][key] or {}

  for i = 1, select("#", ...) do
    local value = select(i, ...)
    table.insert(M.check[group_name][key], vim.deepcopy(value))
  end
end

local args_store = function(name, mock)
  return setmetatable({}, {
    __index = function(_, key)
      return function(...)
        add_check_value(name, key .. "_args", ...)
        if mock[key] then
          return mock[key](...)
        end
      end
    end,
  })
end

local buffer_helper_mock = {
  current_buffer_nr = function()
    return 1
  end,
  current_line_nr = function()
    return 1
  end,
  add_hl_group = function()
    M.values.hl_id = M.values.hl_id + 1
    return M.values.hl_id
  end,
  text_under_cursor = function()
    return M.values.user_text
  end,
}

local template_sender_mock = {
  ---@diagnostic disable-next-line: unused-local
  stream = function(_adapter_model, _template, _user_input, callback)
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function()
      M.check.template_sender_stream_select_called = true
    end
    callback(M.values.scratch_buf, M.values.ai_text)
  end,
  ---@diagnostic disable-next-line: unused-local
  send = function(_adapter_model, template, _user_input)
    if template == tpl_grammar then
      return M.values.ai_text
    elseif template == tpl_lang then
      return M.values.lang_code
    end

    error("unexpected template")
  end,
}

M.buffhelp = args_store("buffer_helper", buffer_helper_mock)

M.template_sender = args_store("template_sender", template_sender_mock)

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

M.reset()

return M
