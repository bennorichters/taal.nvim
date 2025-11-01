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

  M.improve_grammar = commands.improve_grammar
  M.suggest_grammar = commands.suggest_grammar
  M.apply_suggestion = commands.apply_suggestion
  M.set_spelllang = commands.set_spelllang
  M.interactive = commands.interactive
end

return M
