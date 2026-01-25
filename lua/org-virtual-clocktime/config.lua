---@class OrgVirtualClocktimeConfig
---@field hl_group string Highlight group for virtual text
---@field update_events string[] Events that trigger updates
---@field format fun(minutes: number): string Format function to display time
---@field enabled boolean Whether the plugin is enabled
local M = {}

---@type OrgVirtualClocktimeConfig
M.options = {
  hl_group = "@comment",
  update_events = {
    "BufEnter",
    "BufWritePost",
    "InsertLeave",
  },
  format = function(minutes)
    local hours = math.floor(minutes / 60)
    local mins = minutes % 60
    return string.format("=> %d:%02d", hours, mins)
  end,
  enabled = true,
}

---@param opts? OrgVirtualClocktimeConfig
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.options, opts or {})
end

return M
