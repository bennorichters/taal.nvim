local log = require("kitt.log")

local M = { line = 0, content = "" }

function M:new(obj)
  obj = obj or {}
  setmetatable(obj, self)
  self.__index = self

  return obj
end

function M:create_scratch_buffer()
  local bufnr = vim.api.nvim_create_buf(true, true)

  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)

  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].filetype = "markdown"

  return bufnr
end

function M:write(delta, buf)
  log.fmt_trace("response_writer delta=%s", delta)

  delta:gsub(".", function(c)
    if c == "\n" then
      log.fmt_trace("response_writer line=%s content=%s", self.line, self.content)
      vim.api.nvim_buf_set_lines(buf, self.line, -1, false, { self.content })
      self.line = self.line + 1
      self.content = ""
    else
      self.content = self.content .. c
    end
  end)

  if self.content then
    log.fmt_trace("response_writer -write rest- line=%s content=%s", self.line, self.content)
    vim.api.nvim_buf_set_lines(buf, self.line, -1, false, { self.content })
  end
end

return M
