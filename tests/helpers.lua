local M = {}

M.new_child_with_set = function(code)
  local child = MiniTest.new_child_neovim()

  local T = MiniTest.new_set({
    hooks = {
      pre_case = function()
        child.restart({ "-u", "scripts/minimal_init.lua" })
        child.lua("log = require('taal.log')")
        child.lua("log.new({ level = 'trace'}, true)")
        child.lua("log.trace('test log started in child process')")
        child.lua(code)
      end,
      post_once = child.stop,
    },
  })

  return child, T
end

M.enable_log = function()
  local log = require("taal.log")
  log.new({ level = "trace" }, true)
  log.trace("test log started")
end

return M
