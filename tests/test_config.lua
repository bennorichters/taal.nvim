require("tests.helpers").enable_log()

local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality
local config = require("taal.config")

local T = new_set()

T["config"] = new_set()

T["config"]["no_setup"] = function()
  eq(config.settings, nil)
end

T["config"]["setup.defaults"] = function()
  config.setup()
  eq(config.settings, config.defaults)
end

T["config"]["setup.change_timeout"] = function()
  config.setup({ timeout = 10 })
  local expected = vim.fn.deepcopy(config.defaults)
  expected.timeout = 10
  eq(config.settings, expected)
end

T["config"]["setup.adapter.grammar"] = function()
  config.setup({ commands = { grammar = { adapter = "claude" } } })
  local expected = vim.fn.deepcopy(config.defaults)
  expected.commands.grammar.adapter = "claude"
  eq(config.settings, expected)
end

T["config"]["setup.invalid_default_adapter"] = function()
  config.setup({ adapter = "x" })
  eq(config.settings.adapter, "gemini")
end

T["config"]["setup.invalid_command_grammar_adapter"] = function()
  config.setup({ commands = { grammar = { adapter = "x" } } })
  eq(config.settings.commands.grammar.adapter, nil)
end

T["config"]["setup.invalid_command_spelllang_adapter"] = function()
  config.setup({ commands = { set_spelllang = { adapter = "x" } } })
  eq(config.settings.commands.set_spelllang.adapter, nil)
end

T["config"]["setup.invalid_command_spelllang_adapter"] = function()
  config.setup({ commands = { set_spelllang = { adapter = "x" } } })
  eq(config.settings.commands.set_spelllang.adapter, nil)
end

T["config"]["setup.invalid_command_interact_adapter"] = function()
  config.setup({ commands = { interact = { adapter = "x" } } })
  eq(config.settings.commands.interact.adapter, nil)
end

return T
