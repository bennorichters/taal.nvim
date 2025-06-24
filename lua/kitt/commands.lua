local tpl_grammar = require("kitt.templates.grammar")
local tpl_interact = require("kitt.templates.interact_with_content")
local tpl_minutes = require("kitt.templates.minutes")
local tpl_recognize_language = require("kitt.templates.recognize_language")

local differ = require("kitt.diff")

local M = { suggestions = {} }

local function delete_suggestions()
  for _, suggestion in ipairs(M.suggestions) do
    vim.fn.matchdelete(suggestion["matchid"])
  end

  for i = #M.suggestions, 1, -1 do
    table.remove(M.suggestions, i)
  end
end

M.setup = function(buffer_helper, template_sender)
  M.buffer_helper = buffer_helper
  M.template_sender = template_sender

  vim.api.nvim_create_autocmd("InsertEnter", { callback = delete_suggestions })

  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
      local line_nr = vim.fn.line(".")
      local col_nr = vim.fn.col(".")
      for _, suggestion in ipairs(M.suggestions) do
        if line_nr == suggestion["line"] and
            col_nr >= suggestion["left"] and
            col_nr <= suggestion["right"] then
          vim.notify(suggestion["improvement"])
        end
      end
    end,
  })
end

M.ai_improve_grammar = function()
  M.template_sender(tpl_grammar, true, M.buffer_helper.current_line())
end

M.ai_suggest_grammar = function()
  local original = M.buffer_helper.current_line()
  local ai_improvement = M.template_sender(tpl_grammar, false, original)

  local cl = differ.change_location(original, ai_improvement)

  local line_number = vim.fn.line(".")
  delete_suggestions()
  for _, c in ipairs(cl) do
    local position = { line_number, c["left"], c["right"] - c["left"] + 1 }
    local id = vim.fn.matchaddpos("SpellBad", { position })
    table.insert(M.suggestions, {
      line = line_number,
      left = c["left"],
      right = c["right"],
      improvement = c["improvement"],
      matchid = id,
    })
  end
end

M.ai_set_spelllang = function()
  local content = M.template_sender(tpl_recognize_language, false, M.buffer_helper.current_line())
  if (content) then
    vim.cmd("set spelllang=" .. content)
  end
end

M.ai_write_minutes = function()
  M.template_sender(tpl_minutes, true, M.buffer_helper.visual_selection())
end

M.ai_interactive = function()
  vim.ui.input({ prompt = "Give instructions: " }, function(command)
    if command then
      M.template_sender(tpl_interact, true, command, M.buffer_helper.visual_selection())
    end
  end)
end

return M
