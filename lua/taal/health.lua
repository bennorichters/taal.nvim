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
  else
    vim.health.ok("plenary available")
  end

  local ok_adapters, wrong_adapters = config.adapters_supported()
  if ok_adapters then
    vim.health.ok("all configured adapters are supported")
  else
    for _, key in ipairs(wrong_adapters) do
      vim.health.error("Unsupported adapter" .. key)
    end
  end

  local ok_api_keys, missing_keys = config.keys_available()
  if ok_api_keys then
    vim.health.ok("all API keys for used adapters available")
  else
    for _, key in ipairs(missing_keys) do
      vim.health.error("API key missing for adapter '" .. key)
    end
  end
end

return M
