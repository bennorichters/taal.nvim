local new_set = MiniTest.new_set
local expect, eq = MiniTest.expect, MiniTest.expect.equality
local config = require("kitt.config")

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

local T = new_set()

T["config"] = new_set()

T["config"]["no_setup"] = function()
  eq(config.settings, nil)
end

T["config"]["setup.defaults"] = function()
  config.setup()
  eq(config.settings, defaults)
end

T["config"]["setup.change_timeout"] = function()
  config.setup({ timeout = 10 })
  local expected = vim.fn.deepcopy(defaults)
  expected.timeout = 10
  eq(config.settings, expected)
end

T["config"]["setup.invalid_adapter"] = function()
  expect.error(config.setup, nil, { adapter = "x" })
  expect.error(config.setup, nil, { commands = { improve_grammar = { adapter = "x" } } })
  expect.error(config.setup, nil, { commands = { suggest_grammar = { adapter = "x" } } })
  expect.error(config.setup, nil, { commands = { set_spellang = { adapter = "x" } } })
  expect.error(config.setup, nil, { commands = { interact = { adapter = "x" } } })
end

return T
