local supported_adapters = {
  claude = true,
  gemini = true,
  ollama = true,
  openai_responses = true,
}

local M = {}

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
  M.user_config = settings or {}

  local adpts = M.all_adapters()
  local ok = M.adapters_supported(adpts)
  if ok then
    M.settings = vim.tbl_deep_extend("force", M.defaults, settings or {})
  else
    M.settings = M.defaults
  end
end

M.all_adapters = function()
  local adapter_used = {}

  if M.user_config.adapter then
    adapter_used[M.user_config.adapter] = true
  else
    adapter_used[M.defaults.adapter] = true
  end

  if M.user_config.commands then
    for cmd, _ in pairs(M.user_config.commands) do
      if M.user_config.commands[cmd].adapter then
        adapter_used[M.user_config.commands[cmd].adapter] = true
      end
    end
  end

  local result = {}
  for k, _ in pairs(adapter_used) do
    table.insert(result, k)
  end

  table.sort(result)

  return result
end

M.adapters_supported = function(adpts)
  local result = {}
  for _, adpt in pairs(adpts) do
    if not supported_adapters[adpt] then
      table.insert(result, adpt)
    end
  end

  return #result == 0, result
end

M.adapters_key_available = function(adpts)
  local result = {}
  for _, adpt in pairs(adpts) do
    if supported_adapters[adpt] then
      local key = os.getenv(string.upper(adpt) .. "_API_KEY")
      if not key or #key == 0 then
        table.insert(result, adpt)
      end
    end
  end

  return #result == 0, result
end

M.keys_available = function()
  return true, {}
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
