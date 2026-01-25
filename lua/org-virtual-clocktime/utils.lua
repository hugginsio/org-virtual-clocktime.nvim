local M = {}

---Format duration in minutes to HH:MM string
---@param minutes number
---@return string
function M.format_duration(minutes)
  local hours = math.floor(minutes / 60)
  local mins = minutes % 60
  return string.format("%d:%02d", hours, mins)
end

---Check if buffer is a valid org file
---@param bufnr number
---@return boolean
function M.is_valid_org_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local filetype = vim.bo[bufnr].filetype
  return filetype == "org"
end

---Get orgmode instance safely
---@return table|nil
function M.get_orgmode()
  local ok, orgmode = pcall(require, "orgmode")
  if not ok or not orgmode then
    return nil
  end

  -- Ensure orgmode is initialized
  if not orgmode.files then
    return nil
  end

  return orgmode
end

---Log debug message
---@param msg string
---@param level? number
function M.log(msg, level)
  level = level or vim.log.levels.DEBUG
  vim.notify("[org-virtual-clocktime] " .. msg, level)
end

return M
