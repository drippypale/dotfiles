local M = {}

-- Import the bit library for bitwise operations
local bit = require 'bit'

-- Namespace for virtual text overlays
local ns_id = vim.api.nvim_create_namespace 'nvim_rtl'

-- UTF-8 Iterator
local function utf8_iter(s)
  local i = 1
  local len = #s
  return function()
    if i > len then
      return nil
    end
    local c = s:byte(i)
    local size = 1
    if c >= 0xF0 then
      size = 4
    elseif c >= 0xE0 then
      size = 3
    elseif c >= 0xC0 then
      size = 2
    end
    local char = s:sub(i, i + size - 1)
    i = i + size
    return char
  end
end

-- Check if a character is Persian
local function is_persian_char(char, include_space)
  local code = 0
  local c1, c2, c3, c4 = char:byte(1, 4)
  if #char == 1 then
    code = c1
  elseif #char == 2 then
    code = bit.bor(bit.lshift(bit.band(c1, 0x1F), 6), bit.band(c2, 0x3F))
  elseif #char == 3 then
    code = bit.bor(bit.lshift(bit.band(c1, 0x0F), 12), bit.lshift(bit.band(c2, 0x3F), 6), bit.band(c3, 0x3F))
  elseif #char == 4 then
    code = bit.bor(bit.lshift(bit.band(c1, 0x07), 18), bit.lshift(bit.band(c2, 0x3F), 12), bit.lshift(bit.band(c3, 0x3F), 6), bit.band(c4, 0x3F))
  end

  if include_space then
    return (code >= 0x0600 and code <= 0x06FF) or (code >= 0x0750 and code <= 0x077F) or (code == 0x0020) -- Space character
  else
    return (code >= 0x0600 and code <= 0x06FF) or (code >= 0x0750 and code <= 0x077F)
  end
end

-- Check if text contains Persian characters
local function contains_persian(text, include_space)
  for char in utf8_iter(text) do
    if is_persian_char(char, include_space) then
      return true
    end
  end
  return false
end

-- Get highlight chunks for a line
local function get_highlight_chunks(bufnr, line_nr)
  local line = vim.api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1] or ''
  local chunks = {}
  local col = 0
  for char in utf8_iter(line) do
    -- Get highlight group at the current position
    local hl_id = vim.fn.synID(line_nr + 1, col + 1, 1)
    local trans_id = vim.fn.synIDtrans(hl_id)
    local hl_group = vim.fn.synIDattr(trans_id, 'name')
    table.insert(chunks, { char, hl_group })
    col = col + vim.fn.strdisplaywidth(char)
  end
  return chunks
end

-- Reverse Persian segments with highlight
local function reverse_persian_segments_with_highlight(chunks)
  local result = {}
  local current_segment = {}
  local in_persian = false

  local function flush_segment(segment, reverse)
    if reverse then
      for i = #segment, 1, -1 do
        table.insert(result, segment[i])
      end
    else
      for i = 1, #segment do
        table.insert(result, segment[i])
      end
    end
  end

  for _, chunk in ipairs(chunks) do
    local char = chunk[1]
    local hl_group = chunk[2]
    if is_persian_char(char, true) then
      if not in_persian then
        flush_segment(current_segment, false)
        current_segment = {}
        in_persian = true
      end
      table.insert(current_segment, { char, hl_group })
    else
      if in_persian then
        flush_segment(current_segment, true)
        current_segment = {}
        in_persian = false
      end
      table.insert(current_segment, { char, hl_group })
    end
  end

  if in_persian then
    flush_segment(current_segment, true)
  else
    flush_segment(current_segment, false)
  end

  return result
end

-- Update a single line
function M.update_line(bufnr, line_nr)
  local line = vim.api.nvim_buf_get_lines(bufnr, line_nr, line_nr + 1, false)[1] or ''
  if contains_persian(line, false) then
    local chunks = get_highlight_chunks(bufnr, line_nr)
    local reversed_chunks = reverse_persian_segments_with_highlight(chunks)
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, line_nr, 0, {
      virt_text = reversed_chunks,
      virt_text_pos = 'overlay',
      hl_mode = 'combine',
    })
  end
end

-- Update the entire buffer
function M.update_buffer(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for line_nr = 0, line_count - 1 do
    M.update_line(bufnr, line_nr)
  end
end

-- Attach to buffer and set up autocommands
function M.attach_to_buffer(bufnr)
  if vim.b[bufnr].nvim_rtl_attached then
    return
  end
  vim.b[bufnr].nvim_rtl_attached = true

  M.update_buffer(bufnr)

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function()
      vim.schedule(function()
        M.update_buffer(bufnr)
      end)
    end,
  })
end

-- Setup function
function M.setup()
  vim.cmd [[
    augroup NvimRTL
      autocmd!
      autocmd BufReadPost,BufNewFile * lua require('nvim-rtl').attach_to_buffer(vim.fn.bufnr('%'))
    augroup END
  ]]
end

return M
