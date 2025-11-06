local M = {}

function M.check()
  vim.health.start("health checks for taal.nvim")

  if vim.fn.executable("curl") == 1 then
    vim.health.ok("curl is available")
  else
    vim.health.error("curl not found")
  end

  local ok, mod = pcall(require, "plenary")
  if not ok then
    vim.health.error("failed to require 'plenary': " .. tostring(mod))
    return
  end
  vim.health.ok("plenary available")
end

return M

