local supported_adapters = {
  claude = true,
  gemini = true,
  ollama = true,
  openai_responses = true,
}

local M = {}

local function non_default_adapters(settings)
  local result = {}

  if not settings then
    return result
  end

  if settings.adapter then
    table.insert(result, settings.adapter)
  end

  if not settings.commands then
    return result
  end

  for key, _ in pairs(M.defaults.commands) do
    if settings.commands[key] and settings.commands[key].adapter then
      table.insert(result, settings.commands[key].adapter)
    end
  end

  return result
end

M.defaults = {
  log_level = "error",
  timeout = 6000,

  adapters = {
    claude = {
      url = "https://api.anthropic.com",
    },
    gemini = {
      url = "https://generativelanguage.googleapis.com",
    },
    ollama = {
      url = "http://localhost:11434",
    },
    openai_responses = {
      url = "https://api.openai.com",
    },
  },

  adapter = "gemini",
  model = "gemini-2.5-flash",

  commands = {
    grammar = {
      adapter = nil,
      model = nil,
    },
    set_spelllang = {
      adapter = nil,
      model = nil,
    },
    interact = {
      adapter = nil,
      model = nil,
    },
  },
}


M.setup = function(settings)
  M.user_config = settings

  if M.all_adapters_supported(settings) then
    M.settings = vim.tbl_deep_extend("force", M.defaults, settings or {})
  else
    M.settings = M.defaults
  end
end

M.all_adapters_supported = function(settings)
  for _, v in ipairs(non_default_adapters(settings)) do
    if not supported_adapters[v] then
      return false, v
    end
  end

  return true
end

M.get_adapter = function(adapter_name)
  local adapter = require("taal.adapters." .. adapter_name)
  adapter.url = M.settings.adapters[adapter_name].url
  return adapter
end

M.command_adapter_model = function()
  local settings = M.settings
  local cmds = settings.commands

  return {
    grammar = {
      adapter = M.get_adapter(cmds.grammar.adapter or settings.adapter),
      model = cmds.grammar.model or settings.model,
    },
    set_spelllang = {
      adapter = M.get_adapter(cmds.set_spelllang.adapter or settings.adapter),
      model = cmds.set_spelllang.model or settings.model,
    },
    interact = {
      adapter = M.get_adapter(cmds.interact.adapter or settings.adapter),
      model = cmds.interact.model or settings.model,
    },
  }
end

return M
