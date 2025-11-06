local M = {}

M.setup = function(user_cfg)
  local buffer_helper = require("taal.buffer_helper")
  local commands = require("taal.commands")
  local config = require("taal.config")
  local log = require("taal.log")
  local post = require("plenary.curl").post
  local response_writer = require("taal.response_writer")
  local template_sender_factory = require("taal.template_sender")

  config.setup(user_cfg)

  log.new({ level = config.settings.log_level }, true)
  log.trace("taal.nvim log started")
  log.fmt_info("user config: %s", user_cfg)

  local template_sender = template_sender_factory(post, response_writer, config.settings.timeout)
  buffer_helper.setup()
  commands.setup(buffer_helper, template_sender, config.command_adapter_model())

  vim.api.nvim_create_user_command("TaalGrammar", commands.grammar, {
    nargs = "*",
    complete = function()
      return { "scratch", "inlay" }
    end,
  })
  vim.api.nvim_create_user_command("TaalHover", commands.hover, {})
  vim.api.nvim_create_user_command("TaalApplySuggestion", commands.apply_suggestion, {})
  vim.api.nvim_create_user_command("TaalSetSpelllang", commands.set_spelllang, {})
  vim.api.nvim_create_user_command("TaalInteract", commands.interact, {})
end

return M
