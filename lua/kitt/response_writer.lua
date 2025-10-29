local log = require("kitt.log")

local M = { bufnr = -1, line = 0, content = "" }
M.__index = M

function M:new(obj)
  obj = obj or {}
  setmetatable(obj, self)

  return obj
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
      log.fmt_trace("response_writer line=%s content=%s", self.line, self.content)
      vim.api.nvim_buf_set_lines(self.bufnr, self.line, -1, false, { self.content })
      self.line = self.line + 1
      self.content = ""
    else
      self.content = self.content .. c
    end
  end)

  if self.content then
    log.fmt_trace("response_writer -write rest- line=%s content=%s", self.line, self.content)
    vim.api.nvim_buf_set_lines(self.bufnr, self.line, -1, false, { self.content })
  end

  vim.api.nvim__redraw({ buf = self.bufnr, flush = true })
end

return M
