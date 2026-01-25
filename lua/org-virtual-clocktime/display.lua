local utils = require("org-virtual-clocktime.utils")
local config = require("org-virtual-clocktime.config")

local api = vim.api

---@class OrgVirtualClocktimeDisplay
---@field ns_id number Namespace ID for extmarks
local M = {}

M.ns_id = api.nvim_create_namespace("orgmode_clocktime_display")

---Clear all virtual text in buffer
---@param bufnr number
function M.clear(bufnr)
  if not api.nvim_buf_is_valid(bufnr) then
    return
  end

  api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
end

---Set virtual text at a specific line
---@param bufnr number
---@param line number 0-indexed line number
---@param text string Display text
---@param hl_group string Highlight group
---@return boolean success
function M.set_extmark(bufnr, line, text, hl_group)
  local line_count = api.nvim_buf_line_count(bufnr)

  if line < 0 or line >= line_count then
    return false
  end

  local ok = pcall(api.nvim_buf_set_extmark, bufnr, M.ns_id, line, 0, {
    virt_text = { { text, hl_group } },
    virt_text_pos = "eol",
    hl_mode = "combine",
  })

  return ok
end

---Update display for a single buffer
---@param bufnr number
function M.update(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()

  if not utils.is_valid_org_buffer(bufnr) then
    return
  end

  if not config.options.enabled then
    M.clear(bufnr)
    return
  end

  M.clear(bufnr)

  local filepath = api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    return
  end

  local orgmode = utils.get_orgmode()
  if not orgmode then
    return
  end

  -- Use load_file which returns a Promise
  local file_promise = orgmode.files:load_file(filepath, { persist = false })

  file_promise
    :next(function(file)
      if not file or not api.nvim_buf_is_valid(bufnr) then
        return
      end

      M._process_file(bufnr, file)
    end)
    :catch(function(err)
      -- Silently handle errors
      if err and type(err) == "string" and not err:match("not found") then
        utils.log("Error processing file: " .. tostring(err), vim.log.levels.DEBUG)
      end
    end)
end

---Process file and display clock times
---@param bufnr number
---@param file OrgFile
---@private
function M._process_file(bufnr, file)
  local format_fn = config.options.format
  local hl_group = config.options.hl_group

  for _, headline in ipairs(file:get_headlines()) do
    local logbook = headline:get_logbook()

    if logbook then
      local total = logbook:get_total_with_active()
      local minutes = total.minutes

      if minutes > 0 then
        local display = format_fn(minutes)

        -- Find the :LOGBOOK: line (convert to 0-indexed)
        local logbook_line = logbook.range.start_line - 1
        M.set_extmark(bufnr, logbook_line, display, hl_group)
      end
    end
  end
end

---Update all org buffers
function M.update_all()
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if utils.is_valid_org_buffer(bufnr) and api.nvim_buf_is_loaded(bufnr) then
      M.update(bufnr)
    end
  end
end

return M
