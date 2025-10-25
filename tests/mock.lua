local M = {}

local ai_text = "The moon is brighter then yesterday."
local user_text = "The moon is more bright then yesterdate."
local scratch_buf = 42

M.check = {}

M.buffhelp = {
  add_hl_group = function()
    return scratch_buf
  end,
  text_under_cursor = function()
    return user_text
  end,
}

M.post = {
  stream = function(template, callback)
    M.check.template = template
    vim.ui.select = function()
      M.check.select_called = true
    end
    callback(scratch_buf, ai_text)
  end,
  send = function()
    return ai_text
  end,
}

return M
