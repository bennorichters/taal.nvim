local log = require("kitt.log")

local supported_adapters = {
  claude = true,
  ollama = true,
  openai_responses = true,
}

local defaults = {
  log_level = "error",
  timeout = 6000,

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
    local message = string.format("unsupported adapter %s", adapter)
    log.error(message)
    error(message)
  end

  return true
end

local function validate_adapters(config)
    return not config
    or (not config.adapter or is_adapter_supported(config.adapter))
      and (not config.commands
        or (
          (
            not (config.commands.improve_grammar and config.commands.improve_grammar.adapter)
            or is_adapter_supported(config.commands.improve_grammar.adapter)
          )
        )
        and (
            not (config.commands.suggest_grammar and config.commands.suggest_grammar.adapter)
            or is_adapter_supported(config.commands.suggest_grammar.adapter)
        )
        and (
            not (config.commands.set_spellang and config.commands.set_spellang.adapter)
            or is_adapter_supported(config.commands.set_spellang.adapter)
        )
        and (
            not (config.commands.interact and config.commands.interact.adapter)
            or is_adapter_supported(config.commands.interact.adapter)
        )
     )
end

local M = {}

M.setup = function(config)
  if validate_adapters(config)
  then
    M.settings = vim.tbl_deep_extend("force", defaults, config or {})
  end
end

M.command_adapter_model = function()
  local settings = M.settings
  local cmds = settings.commands

  return {
    improve_grammar = {
      adapter = require("kitt.adapters." .. (cmds.improve_grammar.adapter or settings.adapter)),
      model = cmds.improve_grammar.model or settings.model,
    },
    suggest_grammar = {
      adapter = require("kitt.adapters." .. (cmds.suggest_grammar.adapter or settings.adapter)),
      model = cmds.suggest_grammar.model or settings.model,
    },
    set_spellang = {
      adapter = require("kitt.adapters." .. (cmds.set_spellang.adapter or settings.adapter)),
      model = cmds.set_spellang.model or settings.model,
    },
    interact = {
      adapter = require("kitt.adapters." .. (cmds.interact.adapter or settings.adapter)),
      model = cmds.interact.model or settings.model,
    },
  }
end

return M
