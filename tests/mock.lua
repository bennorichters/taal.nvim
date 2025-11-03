local M = {}

M.values = {
  ai_text = "The moon is brighter then yesterday.",
  user_text = "The moon is more bright then yesterdate.",
  scratch_buf = 42,
}

M.check = {}

M.buffhelp = {
  current_buffer_nr = function()
    return 1
  end,
  current_line_nr = function()
    return 1
  end,
  add_hl_group = function(info)
    M.check.add_hl_group_info = M.check.add_hl_group_info or {}
    local copy = vim.deepcopy(info)
    table.insert(M.check.add_hl_group_info, copy)
    return M.values.scratch_buf
  end,
  delete_hl_group = function() end,
  text_under_cursor = function()
    return M.values.user_text
  end,
}

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
  set_spellang = {
    adapter = "",
    model = "",
  },
  interact = {
    adapter = "",
    model = "",
  },
}

return M
