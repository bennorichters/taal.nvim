local original_values = {
  ai_text = "The moon is brighter then yesterday.",
  user_text = "The moon is more bright then yesterdate.",
  scratch_buf = 42,
  hl_id = 100,
}

local M = {}

M.reset = function()
  M.values = vim.deepcopy(original_values)
  M.check = {}
end

M.reset()

local buffhelp_functions = {
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

M.add_check_value = function(key, ...)
  M.check[key] = M.check[key] or {}

  for i = 1, select("#", ...) do
    local value = select(i, ...)
    table.insert(M.check[key], vim.deepcopy(value))
  end
end

M.buffhelp = setmetatable({}, {
  __index = function(_, key)
    return function(...)
      M.add_check_value(key .. "_args", ...)
      if buffhelp_functions[key] then
        return buffhelp_functions[key]()
      end
    end
  end,
})

M.template_sender = {
  stream = function(_, template, _, callback)
    M.check.template = template
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.select = function()
      M.check.select_called = true
    end
    callback(M.values.scratch_buf, M.values.ai_text)
  end,
  send = function()
    return M.values.ai_text
  end,
}

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

return M
