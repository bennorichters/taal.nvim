local M = {}

M.values = {
  ai_text = "The moon is brighter then yesterday.",
  user_text = "The moon is more bright then yesterdate.",
  scratch_buf = 42,
}

M.check = {}

M.buffhelp = {
  add_hl_group = function()
    return M.values.scratch_buf
  end,
  text_under_cursor = function()
    return M.values.user_text
  end,
}

M.post = {
  stream = function(template, _, callback)
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

return M
