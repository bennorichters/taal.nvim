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

T["config"]["template_fn.default"] = function()
  config.setup()

  local fn = config.settings.template_fn
  local default_template = { foo = "bar" }
  local template = fn("grammar", default_template, { "fooz", "barz" })
  eq(template, default_template)
end

-- T["config"]["template_fn.grammar"] = function()
--   -- config.setup({template})
--
--   local fn = config.template_fn()
--   local default_template = { foo = "bar" }
--   local template = fn("grammar", default_template, "fooz", "barz")
--   eq(template, default_template)
-- end

T["config"]["setup.adapter.grammar"] = function()
  config.setup({ commands = { grammar = { adapter = "claude" } } })
  local expected = vim.fn.deepcopy(config.defaults)
  expected.commands.grammar.adapter = "claude"
  eq(config.settings, expected)
end

T["config"]["setup.invalid_default_adapter"] = function()
  config.setup({ adapter = "x" })
  eq(config.settings, config.defaults)
end

T["config"]["setup.invalid_command_grammar_adapter"] = function()
  config.setup({ commands = { grammar = { adapter = "x" } } })
  eq(config.settings, config.defaults)
end

T["config"]["setup.invalid_command_spelllang_adapter"] = function()
  config.setup({ commands = { set_spelllang = { adapter = "x" } } })
  eq(config.settings, config.defaults)
end

T["config"]["setup.invalid_command_spelllang_adapter"] = function()
  config.setup({ commands = { set_spelllang = { adapter = "x" } } })
  eq(config.settings, config.defaults)
end

T["config"]["setup.invalid_command_interact_adapter"] = function()
  config.setup({ commands = { interact = { adapter = "x" } } })
  eq(config.settings, config.defaults)
end

T["config"]["all_adapters.default_not_overriden"] = function()
  config.setup({
    commands = { grammar = { adapter = "x" }, interact = { adapter = "a" } },
  })

  eq({ "a", "gemini", "x" }, config.all_adapters())
end

T["config"]["all_adapters.default_overriden"] = function()
  config.setup({
    adapter = "y",
    commands = { grammar = { adapter = "x" }, interact = { adapter = "a" } },
  })

  eq({ "a", "x", "y" }, config.all_adapters())
end

T["config"]["adapters_supported.ok"] = function()
  config.setup({ adapter = "claude" })
  eq(config.adapters_supported(config.all_adapters()), true)
end

T["config"]["adapters_supported.one_ok_two_wrong"] = function()
  config.setup({
    commands = { grammar = { adapter = "x" }, interact = { adapter = "y" } },
  })

  local ok, adpts = config.adapters_supported(config.all_adapters())

  eq(ok, false)
  eq(adpts, { "x", "y" })
end

T["config"]["adapters_key_available.gemini_exists"] = function()
  local env_var = "GEMINI_API_KEY"
  local old_env_api_key = os.getenv(env_var)
  vim.fn.setenv(env_var, "test_key")

  config.setup()
  eq(config.adapters_key_available(config.all_adapters()), true)

  if old_env_api_key then
    vim.fn.setenv(env_var, old_env_api_key)
  end
end

T["config"]["adapters_key_available.gemini_does_not_exist"] = function()
  local env_var = "GEMINI_API_KEY"
  local old_env_api_key = os.getenv(env_var)
  vim.fn.setenv(env_var, "")

  config.setup()
  local ok, adpts = config.adapters_key_available(config.all_adapters())
  eq(ok, false)
  eq(adpts, { "gemini" })

  if old_env_api_key then
    vim.fn.setenv(env_var, old_env_api_key)
  end
end

return T
