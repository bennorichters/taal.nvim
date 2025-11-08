local config = require("taal.config")

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
  else
    vim.health.ok("plenary available")
  end

  local ok_adapters, wrong_adapter = config.all_adapters_supported(config.user_config)
  if ok_adapters then
    vim.health.ok("all configured adapters are supported")
  else
    vim.health.error("adapter '" .. wrong_adapter .. "' is not supported.")
  end
end

return M
