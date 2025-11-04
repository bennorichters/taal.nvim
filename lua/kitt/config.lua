local supported_adapters = {
  claude = true,
  ollama = true,
  openai_responses = true,
}

local defaults = {
  log_level = "error",
  timeout = 6000,

  adapters = {
    claude = {
      endpoint = "https://api.anthropic.com/v1/messages",
    },
    ollama = {
      endpoint = "http://localhost:11434/api/chat",
    },
    openai_responses = {
      endpoint = "https://api.openai.com/v1/responses",
    },
  },

  adapter = "ollama",
  model = "gemma3",

  commands = {
    improve_grammar = {
      adapter = nil,
      model = nil,
    },
    suggest_grammar = {
      adapter = nil,
      model = nil,
    },
    set_spellang = {
      adapter = nil,
      model = nil,
    },
    interact = {
      adapter = nil,
      model = nil,
    },
  },
}

local function is_adapter_supported(adapter)
  if not supported_adapters[adapter] then
    error("unsupported adapter: " .. adapter)
  end

  return true
end

local function validate_adapters(settings)
  if not settings then
    return true
  end

  if settings.adapter and not is_adapter_supported(settings.adapter) then
    return false
  end

  if not settings.commands then
    return true
  end

  for key, _ in pairs(defaults.commands) do
    if
      settings.commands[key]
      and settings.commands[key].adapter
      and not is_adapter_supported(settings.commands[key].adapter)
    then
      return false
    end
  end

  return true
end

local M = {}

M.setup = function(settings)
  if validate_adapters(settings) then
    M.settings = vim.tbl_deep_extend("force", defaults, settings or {})
  end
end

M.get_adapter = function(adapter_name)
  local adapter = require("kitt.adapters." .. adapter_name)
  adapter.endpoint = M.settings.adapters[adapter_name].endpoint
  return adapter
end

M.command_adapter_model = function()
  local settings = M.settings
  local cmds = settings.commands

  return {
    improve_grammar = {
      adapter = M.get_adapter(cmds.improve_grammar.adapter or settings.adapter),
      model = cmds.improve_grammar.model or settings.model,
    },
    suggest_grammar = {
      adapter = M.get_adapter(cmds.suggest_grammar.adapter or settings.adapter),
      model = cmds.suggest_grammar.model or settings.model,
    },
    set_spellang = {
      adapter = M.get_adapter(cmds.set_spellang.adapter or settings.adapter),
      model = cmds.set_spellang.model or settings.model,
    },
    interact = {
      adapter = M.get_adapter(cmds.interact.adapter or settings.adapter),
      model = cmds.interact.model or settings.model,
    },
  }
end

return M
