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

local M = {}

M.setup = function(config)
  M.options = vim.tbl_deep_extend("force", defaults, config or {})
end

M.get = function()
  return M.options
end

M.command_adapter_model = function()
  local opts = M.options
  local cmds = opts.commands

  return {
    improve_grammar = {
      adapter = require("kitt.adapters." .. (cmds.improve_grammar.adapter or opts.adapter)),
      model = cmds.improve_grammar.model or opts.model,
    },
    suggest_grammar = {
      adapter = require("kitt.adapters." .. (cmds.suggest_grammar.adapter or opts.adapter)),
      model = cmds.suggest_grammar.model or opts.model,
    },
    set_spellang = {
      adapter = require("kitt.adapters." .. (cmds.set_spellang.adapter or opts.adapter)),
      model = cmds.set_spellang.model or opts.model,
    },
    interact = {
      adapter = require("kitt.adapters." .. (cmds.interact.adapter or opts.adapter)),
      model = cmds.interact.model or opts.model,
    },
  }
end

return M
