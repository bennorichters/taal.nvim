local log = require("kitt.log")
log.new({}, true)
log.error("test")

print(vim.inspect(log))
