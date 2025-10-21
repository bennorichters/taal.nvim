local buffer_helper = require("kitt.buffer_helper")
local commands = require("kitt.commands")
local config = require("kitt.config")
local send_request_factory = require("kitt.send_request")
local template_sender_factory = require("kitt.template_sender")

local log = require("kitt.log")

local M = {}

M.setup = function(user_cfg)
  config.setup(user_cfg)
  log.new({ level = config.get().log_level }, true)
  log.trace("kitt.nvim log started")
  log.fmt_info("user config: %s", user_cfg)

  _G.kitt_ns = vim.api.nvim_create_namespace("kitt")
  vim.api.nvim_set_hl(0, "KittIssue", { bg = "DarkRed", fg = "White" })
  vim.api.nvim_set_hl(0, "KittImprovement", { bg = "DarkGreen", fg = "White" })

  local post
  local cfg_post = config.get().post
  if cfg_post == "curl" then
    post = require("plenary.curl").post
  elseif cfg_post == "mock" then
    post = require("kitt.mock_post")
  else
    log.fmt_error("Unknown 'post' option: " .. cfg_post)
    error("Unknown 'post' option")
  end

  local endpoint = "https://api.openai.com/v1/responses"
  local key = os.getenv("OPENAI_API_KEY")

  local send_request = send_request_factory(post, endpoint, key)
  local template_sender = template_sender_factory(send_request, config.get().timeout)

  commands.setup(buffer_helper, template_sender)

  M.ai_improve_grammar = commands.ai_improve_grammar
  M.ai_suggest_grammar = commands.ai_suggest_grammar
  M.ai_apply_suggestion = commands.ai_apply_suggestion
  M.ai_set_spelllang = commands.ai_set_spelllang
  M.ai_write_minutes = commands.ai_write_minutes
  M.ai_interactive = commands.ai_interactive
end

return M
