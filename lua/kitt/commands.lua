local differ = require("kitt.diff")
local log = require("kitt.log")
local tpl_grammar = require("kitt.templates.grammar")
local tpl_interact = require("kitt.templates.interact_with_content")
local tpl_minutes = require("kitt.templates.minutes")
local tpl_recognize_language = require("kitt.templates.recognize_language")

local M = { suggestions = {} }

local function delete_suggestions()
  for _, suggestion in ipairs(M.suggestions) do
    vim.fn.matchdelete(suggestion.matchid)
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
        if
          line_nr == suggestion.line
          and col_nr >= suggestion.a_start
          and col_nr <= suggestion.a_end
        then
          vim.notify(suggestion.b_text)
          return
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
  local ai_text = M.template_sender(tpl_grammar, false, original)

  local loc = differ.diff(original, ai_text)

  local line_number = vim.fn.line(".")
  delete_suggestions()
  for _, c in ipairs(loc) do
    local position = { line_number, c.a_start, c.a_end - c.a_start }
    local id = vim.fn.matchaddpos("SpellBad", { position })
    table.insert(M.suggestions, {
      line = line_number,
      a_start = c.a_start,
      a_end = c.a_end,
      b_text = c.b_text,
      matchid = id,
    })
  end
end

M.ai_apply_suggestion = function()
  local line_nr = vim.fn.line(".")
  local col_nr = vim.fn.col(".")

  local length_diff = 0
  local applied_index = 0
  for i, sug in ipairs(M.suggestions) do
    if
      applied_index == 0
      and line_nr == sug.line
      and col_nr >= sug.a_start
      and col_nr < sug.a_end
    then
      applied_index = i
      local current_line = M.buffer_helper.current_line()
      local content = string.sub(current_line, 1, sug.a_start - 1)
        .. sug.b_text
        .. string.sub(current_line, sug.a_end)

      vim.api.nvim_buf_set_lines(0, sug.line - 1, sug.line, false, { content })
      vim.fn.matchdelete(sug.matchid)

      length_diff = sug.a_end - sug.a_start - #sug.b_text
      if length_diff == 0 then
        return
      end
    elseif applied_index > 0 then
      vim.fn.matchdelete(sug.matchid)

      sug.a_start = sug.a_start - length_diff
      sug.a_end = sug.a_end - length_diff
      local position = { line_nr, sug.a_start, sug.a_end - sug.a_start }
      sug.matchid = vim.fn.matchaddpos("SpellBad", { position })
    end
  end

  if applied_index > 0 then
    table.remove(M.suggestions, applied_index)
  end
end

M.ai_set_spelllang = function()
  local content = M.template_sender(tpl_recognize_language, false, M.buffer_helper.current_line())
  if content then
    log.fmt_info("set spellang=%s", content)
    vim.cmd("set spelllang=" .. content)
  else
    log.fmt_error("no content returned for setting spellang")
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
