local M = {}

M.setup = function(user_cfg)
  local buffer_helper = require("kitt.buffer_helper")
  local commands = require("kitt.commands")
  local config = require("kitt.config")
  local log = require("kitt.log")
  local post = require("plenary.curl").post
  local response_writer = require("kitt.response_writer")
  local template_sender_factory = require("kitt.template_sender")

  config.setup(user_cfg)

  log.new({ level = config.settings.log_level }, true)
  log.trace("kitt.nvim log started")
  log.fmt_info("user config: %s", user_cfg)

  local template_sender = template_sender_factory(post, response_writer, config.settings.timeout)
  buffer_helper.setup()
  commands.setup(buffer_helper, template_sender, config.command_adapter_model())

  vim.api.nvim_create_user_command("KittGrammar", commands.grammar, { nargs = "*" })
  vim.api.nvim_create_user_command("KittApplySuggestion", commands.apply_suggestion, {})
  vim.api.nvim_create_user_command("KittSetSpelllang", commands.set_spelllang, {})
  vim.api.nvim_create_user_command("KittInteract", commands.interact, {})
end

return M
