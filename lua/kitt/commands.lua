local differ = require("kitt.diff")
local log = require("kitt.log")
local text_prompt = require("kitt.text_prompt")
local tpl_grammar = require("kitt.templates.grammar")
local tpl_interact = require("kitt.templates.interact_with_content")
local tpl_recognize_language = require("kitt.templates.recognize_language")

local M = { all_diff_info = {} }

local function apply_visual_effects(info, inlay)
  info.hl_id = M.buffer_helper.add_hl_group(info)
  if inlay or info.inlay_id then
    info.inlay_id = M.buffer_helper.add_inlay(info)
  end
end

local function delete_visual_effects(info)
  M.buffer_helper.delete_hl_group(info.buf_nr, info.hl_id)

  if info.inlay_id then
    M.buffer_helper.delete_inlay(info.buf_nr, info.inlay_id)
  end
end

local function delete_suggestions()
  local buf_nr = M.buffer_helper.current_buffer_nr()
  for _, info in ipairs(M.all_diff_info) do
    if info.buf_nr == buf_nr then
      delete_visual_effects(info)
    end
  end

  for i = #M.all_diff_info, 1, -1 do
    table.remove(M.all_diff_info, i)
  end
end

local function create_diff_info(buf_line_text, col_start, col_end, alt_text, inlay)
  local info = {
    buf_nr = buf_line_text.buf_nr,
    line_nr = buf_line_text.line_nr,
    col_start = col_start,
    col_end = col_end,
    hl_group = buf_line_text.hl_group,
    alt_text = alt_text,
  }

  apply_visual_effects(info, inlay)

  return info
end

local function apply_diff_effects(buf_line_text_a, buf_line_text_b, inlay)
  log.trace("apply_diff_hl_groups a=%s", buf_line_text_a)
  log.trace("apply_diff_hl_groups b=%s", buf_line_text_b)

  local diff_info = {}
  local locations = differ.diff(buf_line_text_a.text, buf_line_text_b.text)

  for _, loc in ipairs(locations) do
    log.trace("diff info: %s", loc)

    local info_a = create_diff_info(buf_line_text_a, loc.a_start, loc.a_end, loc.b_text, inlay)
    table.insert(diff_info, info_a)

    if buf_line_text_b.buf_nr then
      local info_b = create_diff_info(buf_line_text_b, loc.b_start, loc.b_end, loc.a_text)
      table.insert(diff_info, info_b)
    end
  end

  return diff_info
end

local function improve_grammar(inlay)
  local buf_nr = M.buffer_helper.current_buffer_nr()
  local line_nr = M.buffer_helper.current_line_nr()
  local text = M.buffer_helper.text_under_cursor()

  log.fmt_trace("ai_improve_grammar. buf_nr=%s, line_nr=%s, text=%s", buf_nr, line_nr, text)

  local ui_select = text_prompt.process_buf_text()
  local callback = function(scratch_buf, ai_text)
    log.fmt_trace("ai_improve_grammar-callback scratch_buf=%s, ai_text=%s", scratch_buf, ai_text)
    M.all_diff_info = apply_diff_effects(
      { hl_group = "KittIssue", buf_nr = buf_nr, line_nr = line_nr, text = text },
      { hl_group = "KittImprovement", buf_nr = scratch_buf, line_nr = 1, text = ai_text },
      inlay
    )

    ui_select()
  end

  delete_suggestions()
  M.template_sender.stream(M.adapter_model["improve_grammar"], tpl_grammar, text, callback)
end

local function suggest_grammar(inlay)
  local original = M.buffer_helper.text_under_cursor()
  local ai_text = M.template_sender.send(M.adapter_model["suggest_grammar"], tpl_grammar, original)

  local buf_nr = M.buffer_helper.current_buffer_nr()
  local line_nr = M.buffer_helper.current_line_nr()
  delete_suggestions()
  M.all_diff_info = apply_diff_effects(
    { hl_group = "KittIssue", buf_nr = buf_nr, line_nr = line_nr, text = original },
    { text = ai_text },
    inlay
  )
end

M.setup = function(buffer_helper, template_sender, adapter_model)
  M.buffer_helper = buffer_helper
  M.template_sender = template_sender
  M.adapter_model = adapter_model

  log.fmt_trace("commands.setup. adapter_model=%s", adapter_model)

  vim.api.nvim_create_autocmd("InsertEnter", { callback = delete_suggestions })
end

M.grammar = function(opts)
  local scratch = opts.fargs[1] == "scratch" or opts.fargs[2] == "scratch"
  local inlay = opts.fargs[1] == "inlay" or opts.fargs[2] == "inlay"

  if
    (#opts.fargs == 1 and not scratch and not inlay)
    or (#opts.fargs == 2 and not (scratch and inlay))
    or #opts.fargs > 2
  then
    return error("wrong arguments supplied")
  end

  if scratch then
    improve_grammar(inlay)
  else
    suggest_grammar(inlay)
  end
end

M.hover = function()
  local buf_nr = M.buffer_helper.current_buffer_nr()
  local line_nr = M.buffer_helper.current_line_nr()
  local col_nr = M.buffer_helper.current_column_nr()
  for _, info in ipairs(M.all_diff_info) do
    if
      info.buf_nr == buf_nr
      and info.line_nr == line_nr
      and info.col_start <= col_nr
      and info.col_end >= col_nr
    then
      M.buffer_helper.show_hover(info.alt_text)
      return
    end
  end
end

M.apply_suggestion = function()
  local buf_nr = M.buffer_helper.current_buffer_nr()
  local line_nr = M.buffer_helper.current_line_nr()
  local col_nr = M.buffer_helper.current_column_nr()

  local length_diff = 0
  local applied_index = 0
  for i, info in ipairs(M.all_diff_info) do
    if info.buf_nr == buf_nr and info.line_nr == line_nr then
      if applied_index == 0 and info.col_start <= col_nr and info.col_end > col_nr then
        applied_index = i
        M.buffer_helper.replace_text(buf_nr, line_nr, info.col_start, info.col_end, info.alt_text)
        delete_visual_effects(info)

        length_diff = info.col_end - info.col_start - #info.alt_text
        if length_diff == 0 then
          break
        end
      elseif applied_index > 0 then
        delete_visual_effects(info)
        info.col_start = info.col_start - length_diff
        info.col_end = info.col_end - length_diff
        -- info.hl_id = M.buffer_helper.add_hl_group(info)
        apply_visual_effects(info)
      end
    end
  end

  if applied_index > 0 then
    table.remove(M.all_diff_info, applied_index)
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
      log.fmt_trace("interact content=%s", template_subs)
      M.template_sender.stream(M.adapter_model["interact"], tpl_interact, template_subs)
    end
  end)
end

return M
