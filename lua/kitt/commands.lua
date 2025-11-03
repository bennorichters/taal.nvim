local differ = require("kitt.diff")
local log = require("kitt.log")
local text_prompt = require("kitt.text_prompt")
local tpl_grammar = require("kitt.templates.grammar")
local tpl_interact = require("kitt.templates.interact_with_content")
local tpl_recognize_language = require("kitt.templates.recognize_language")

local M = { diff_info = {} }

local function delete_suggestions()
  local buf_nr = vim.api.nvim_get_current_buf()
  for _, info in ipairs(M.diff_info) do
    if info.buf_nr == buf_nr then
      M.buffer_helper.delete_hl_group(buf_nr, info.extmark_id)
    end
  end

  for i = #M.diff_info, 1, -1 do
    table.remove(M.diff_info, i)
  end
end

local function show_suggestion()
  local buf_nr = vim.api.nvim_get_current_buf()
  local line_nr = vim.fn.line(".")
  local col_nr = vim.fn.col(".")
  for _, info in ipairs(M.diff_info) do
    if
      info.buf_nr == buf_nr
      and info.line_nr == line_nr
      and info.col_start <= col_nr
      and info.col_end >= col_nr
    then
      vim.notify(info.alt_text)
      return
    end
  end
end

local function apply_diff_hl_groups(a, b)
  log.trace("apply_diff_hl_groups a=%s", a)
  log.trace("apply_diff_hl_groups b=%s", b)

  local diff_info = {}
  local locations = differ.diff(a.text, b.text)

  for _, loc in ipairs(locations) do
    log.trace("diff info: %s", loc)

    local info_a = {
      buf_nr = a.buf_nr,
      line_nr = a.line_nr,
      col_start = loc.a_start,
      col_end = loc.a_end,
      hl_group = a.hl_group,
      alt_text = loc.b_text,
    }
    info_a.extmark_id = M.buffer_helper.add_hl_group(info_a)
    table.insert(diff_info, info_a)

    if b.buf_nr then
      local info_b = {
        buf_nr = b.buf_nr,
        line_nr = b.line_nr,
        col_start = loc.b_start,
        col_end = loc.b_end,
        hl_group = b.hl_group,
        alt_text = loc.a_text,
      }
      info_b.extmark_id = M.buffer_helper.add_hl_group(info_b)
      table.insert(diff_info, info_b)
    end
  end

  return diff_info
end

M.setup = function(buffer_helper, template_sender, adapter_model)
  M.buffer_helper = buffer_helper
  M.template_sender = template_sender
  M.adapter_model = adapter_model

  log.fmt_trace("commands.setup. adapter_model=%s", adapter_model)

  vim.api.nvim_create_autocmd("InsertEnter", { callback = delete_suggestions })
  vim.api.nvim_create_autocmd("CursorHold", { callback = show_suggestion })
end

M.improve_grammar = function()
  local buf_nr = vim.api.nvim_get_current_buf()
  local line_nr = vim.fn.line(".")
  local text = M.buffer_helper.text_under_cursor()

  log.fmt_trace("ai_improve_grammar. buf_nr=%s, line_nr=%s, text=%s", buf_nr, line_nr, text)

  local ui_select = text_prompt.process_buf_text()
  local callback = function(scratch_buf, ai_text)
    log.fmt_trace("ai_improve_grammar-callback scratch_buf=%s, ai_text=%s", scratch_buf, ai_text)
    M.diff_info = apply_diff_hl_groups(
      { hl_group = "KittIssue", buf_nr = buf_nr, line_nr = line_nr, text = text },
      { hl_group = "KittImprovement", buf_nr = scratch_buf, line_nr = 1, text = ai_text }
    )

    ui_select()
  end

  delete_suggestions()
  M.template_sender.stream(M.adapter_model["improve_grammar"], tpl_grammar, text, callback)
end

M.suggest_grammar = function()
  local original = M.buffer_helper.text_under_cursor()
  local ai_text = M.template_sender.send(M.adapter_model["suggest_grammar"], tpl_grammar, original)

  local buf_nr = vim.api.nvim_get_current_buf()
  local line_nr = vim.fn.line(".")
  delete_suggestions()
  M.diff_info = apply_diff_hl_groups(
    { hl_group = "KittIssue", buf_nr = buf_nr, line_nr = line_nr, text = original },
    { text = ai_text }
  )
end

M.apply_suggestion = function()
  local buf_nr = vim.api.nvim_get_current_buf()
  local line_nr = vim.fn.line(".")
  local col_nr = vim.fn.col(".")

  local length_diff = 0
  local applied_index = 0
  for i, info in ipairs(M.diff_info) do
    if info.buf_nr == buf_nr and info.line_nr == line_nr then
      if applied_index == 0 and info.col_start <= col_nr and info.col_end > col_nr then
        applied_index = i
        local current_text = M.buffer_helper.text_under_cursor()
        local content = string.sub(current_text, 1, info.col_start)
          .. info.alt_text
          .. string.sub(current_text, info.col_end + 1)

        vim.api.nvim_buf_set_lines(0, info.line_nr - 1, info.line_nr, false, { content })
        M.buffer_helper.delete_hl_group(buf_nr, info.extmark_id)

        length_diff = info.col_end - info.col_start - #info.alt_text
        if length_diff == 0 then
          return
        end
      elseif applied_index > 0 then
        M.buffer_helper.delete_hl_group(buf_nr, info.extmark_id)

        info.col_start = info.col_start - length_diff
        info.col_end = info.col_end - length_diff
        info.extmark_id = M.buffer_helper.add_hl_group(info)
      end
    end
  end

  if applied_index > 0 then
    table.remove(M.diff_info, applied_index)
  end
end

M.set_spelllang = function()
  local code = M.template_sender.send(
    M.adapter_model["set_spellang"],
    tpl_recognize_language,
    M.buffer_helper.text_under_cursor()
  )
  if code then
    log.fmt_info("set spellang=%s", code)
    vim.cmd("set spelllang=" .. code)
  else
    log.fmt_error("no content returned for setting spellang")
  end
end

M.interact = function()
  vim.ui.input({ prompt = "Give instructions: " }, function(command)
    if command then
      local template_subs = command .. "\n\n" .. M.buffer_helper.visual_selection()
      M.template_sender.stream(M.adapter_model["interact"], tpl_interact, template_subs)
    end
  end)
end

return M
