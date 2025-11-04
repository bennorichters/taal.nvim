local log = require("kitt.log")

local M = { bufnr = -1, line = 0, column = 0, content = "" }
M.__index = M

function M:new()
  return setmetatable({}, self)
end

function M:create_scratch_buffer()
  self.bufnr = vim.api.nvim_create_buf(true, true)

  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, self.bufnr)

  vim.bo[self.bufnr].buftype = "nofile"
  vim.bo[self.bufnr].bufhidden = "hide"
  vim.bo[self.bufnr].swapfile = false
  vim.bo[self.bufnr].filetype = "markdown"

  return self.bufnr
end

function M:write(delta)
  log.fmt_trace("response_writer delta=%s", delta)

  delta:gsub(".", function(c)
    if c == "\n" then
      self.line = self.line + 1
      self.column = 0
      vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, true, { "" })
    else
      vim.api.nvim_buf_set_text(self.bufnr, self.line, self.column, self.line, self.column, { c })
      self.column = self.column + 1
    end

    self.content = self.content .. c
  end)

  vim.api.nvim__redraw({ buf = self.bufnr, flush = true })
end

return M
