local log = require("kitt.log")

local M = {}

M.setup = function()
  M.namespace_hl = vim.api.nvim_create_namespace("kitt")
  M.namespace_inlay = vim.api.nvim_create_namespace("kitt")

  log.fmt_trace("buffer_helper.setup kitt namespace=%s", M.namespace_hl)
  vim.api.nvim_set_hl(0, "KittIssue", { bg = "DarkRed", fg = "White" })
  vim.api.nvim_set_hl(0, "KittImprovement", { bg = "DarkGreen", fg = "White" })
  vim.api.nvim_set_hl(0, "KittInlay", { fg = "#A6E22E", italic = true })
end

M.current_buffer_nr = function()
  return vim.api.nvim_get_current_buf()
end

M.current_line_nr = function()
  return vim.fn.line(".")
end

M.current_column_nr = function()
  return vim.fn.col(".")
end

M.add_hl_group = function(info)
  local extmark_id = vim.api.nvim_buf_set_extmark(
    info.buf_nr,
    M.namespace_hl,
    info.line_nr - 1,
    info.col_start,
    { end_row = info.line_nr - 1, end_col = info.col_end, hl_group = info.hl_group }
  )

  log.fmt_trace(
    "add_hl_group info=%s, namespace=%s, created extmark_id=%s",
    info,
    M.namespace_hl,
    extmark_id
  )

  return extmark_id
end

M.delete_hl_group = function(buf_nr, hl_id)
  log.fmt_trace("delete_hl_group buf_nr=%s, hl_id=%s", M.namespace_hl, buf_nr, hl_id)
  vim.api.nvim_buf_del_extmark(buf_nr, M.namespace_hl, hl_id)
end

M.add_inlay = function(info)
  log.fmt_trace("add_inlay: info=%s", info)
  return vim.api.nvim_buf_set_extmark(
    info.buf_nr,
    M.namespace_inlay,
    info.line_nr - 1,
    info.col_end,
    {
      virt_text = { { " " .. info.alt_text, "KittInlay" } },
      virt_text_pos = "inline",
    }
  )
end

M.delete_inlay = function(buf_nr, inlay_id)
  log.fmt_trace("delete_inlay buf_nr=%s, inlay_id=%s", M.namespace_hl, buf_nr, inlay_id)
  vim.api.nvim_buf_del_extmark(buf_nr, M.namespace_inlay, inlay_id)
end

M.text_under_cursor = function()
  local line_number = vim.fn.line(".")
  return vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
end

M.show_hover = function(text)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })

  local ns = vim.api.nvim_create_namespace("hover_popup")
  vim.api.nvim_buf_set_extmark(
    buf,
    ns,
    0,
    0,
    { end_row = 0, end_col = #text, hl_group = "KittInlay" }
  )

  local maxw = vim.fn.strdisplaywidth(text)

  local opts = {
    relative = "cursor",
    row = 1,
    col = 0,
    width = maxw,
    height = 1,
    style = "minimal",
    border = "single",
    focusable = false,
  }
  local win = vim.api.nvim_open_win(buf, false, opts)

  vim.api.nvim_create_autocmd({ "CursorMoved", "BufHidden", "InsertEnter" }, {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, win, true)
    end,
  })
end

M.visual_selection = function()
  local mode = vim.api.nvim_get_mode().mode
  if mode ~= "v" and mode ~= "V" then
    log.fmt_debug("visual_selection: not in visual mode, mode ='%s'. return nil", mode)
    return nil
  end

  local pos_visual_start = vim.fn.getpos("v")
  local start_line, start_col = pos_visual_start[2] - 1, pos_visual_start[3] - 1

  local pos_cursor = vim.fn.getpos(".")
  local end_line, end_col = pos_cursor[2] - 1, pos_cursor[3] - 1

  if end_line < start_line then
    start_line, start_col, end_line, end_col = end_line, end_col, start_line, start_col
  elseif start_line == end_line and end_col < start_col then
    start_col, end_col = end_col, start_col
  end

  log.fmt_trace(
    "visual_selection: start_line=%s, start_col=%s, end_line=%s, end_col=%s",
    start_line,
    start_col,
    end_line,
    end_col
  )

  local selection = vim.api.nvim_buf_get_text(0, start_line, start_col, end_line, end_col, {})
  local one_line = table.concat(selection, "\n")
  log.fmt_trace("visual_selection: selection: %s", one_line)

  return one_line
end

M.set_lines = function(line_nr, content)
  vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { content })
end

M.replace_text = function(buf_nr, line_nr, col_start, col_end, text)
  vim.api.nvim_buf_set_text(buf_nr, line_nr - 1, col_start, line_nr - 1, col_end, { text })
end

return M
