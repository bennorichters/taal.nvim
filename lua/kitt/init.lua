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
  log.new({ level = config.get().log_level }, true)
  log.trace("kitt.nvim log started")
  log.fmt_info("user config: %s", user_cfg)

  local adapter = config.get_adapter()

  local template_sender =
    template_sender_factory(adapter, post, response_writer, config.get().timeout)

  buffer_helper.setup()
  commands.setup(buffer_helper, template_sender)

  M.ai_improve_grammar = commands.ai_improve_grammar
  M.ai_suggest_grammar = commands.ai_suggest_grammar
  M.ai_apply_suggestion = commands.ai_apply_suggestion
  M.ai_set_spelllang = commands.ai_set_spelllang
  M.ai_interactive = commands.ai_interactive
end

return M
