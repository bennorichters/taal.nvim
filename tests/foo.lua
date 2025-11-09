for name, _ in pairs(package.loaded) do
  if name:match("^taal") then
    package.loaded[name] = nil
  end
end
require("taal").setup()

local config = require("taal.config")
config.setup({
  commands = { grammar = { adapter = "gemini" }, interact = { adapter = "claude" } },
})

local ok, adpts = config.adapters_supported()

print(ok, vim.inspect(adpts))

-- local t = {
--   commands = { grammar = { adapter = "y" }, interact = { adapter = "x" } },
-- }

-- for cmd, _ in pairs(t.commands) do
--   print(cmd, t.commands[cmd].adapter)
-- end
