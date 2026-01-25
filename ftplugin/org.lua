-- org-virtual-clocktime ftplugin
-- This file lazy-loads the plugin when an org file is opened.
--
-- IMPORTANT: To configure the plugin, you must EITHER:
--   1. Set vim.g.org_virtual_clocktime_config BEFORE opening any org file, OR
--   2. Call require('org-virtual-clocktime').setup() BEFORE opening any org file
--
-- Once setup() is called (either here or manually), subsequent setup() calls are ignored.

if vim.b.loaded_org_virtual_clocktime then
  return
end

vim.b.loaded_org_virtual_clocktime = true

if vim.g.disable_org_virtual_clocktime then
  return
end

-- Lazy-load the plugin on first org file
if not vim.g.org_virtual_clocktime_setup_done then
  vim.g.org_virtual_clocktime_setup_done = true

  local config = vim.g.org_virtual_clocktime_config or {}
  require("org-virtual-clocktime").setup(config)
else
  -- Plugin already setup, just update this buffer
  vim.schedule(function()
    require("org-virtual-clocktime.display").update(vim.api.nvim_get_current_buf())
  end)
end
