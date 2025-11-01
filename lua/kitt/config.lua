local log = require("kitt.log")

local supported_adapters = {
  claude = true,
  ollama = true,
  openai_responses = true,
}

local defaults = {
  adapter = "ollama",
  log_level = "error",
  timeout = 6000,
}

local M = {}

M.setup = function(config)
  M.options = vim.tbl_deep_extend("force", defaults, config or {})
end

M.get = function()
  return M.options
end

M.get_adapter = function()
  if not supported_adapters[M.options.adapter] then
    local message = "wrong adapter in cfg: " .. M.options.adapter
    log.error(message)
    error(message)
  end

  return require("kitt.adapters." .. M.options.adapter)
end

return M
