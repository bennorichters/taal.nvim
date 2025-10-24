local M = {}

M.prompt = function(target_buffer, target_line, content)
  vim.ui.select({ "replace", "ignore" }, {
    prompt = "Choose what to do with the generated text",
  }, function(choice)
    if choice == "replace" then
      vim.api.nvim_buf_set_lines(target_buffer, target_line, target_line + 1, false, content)
      vim.api.nvim_buf_delete(0, {})
    end
  end)
end

M.process_buf_text = function()
  local target_line = vim.fn.line(".") - 1
  local target_buffer = vim.fn.bufnr()

  return function()
    vim.cmd("redraw")
    local buffer_text = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
    M.prompt(target_buffer, target_line, buffer_text)
  end
end

return M
