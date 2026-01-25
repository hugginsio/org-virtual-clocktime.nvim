local config = require("org-virtual-clocktime.config")
local display = require("org-virtual-clocktime.display")
local utils = require("org-virtual-clocktime.utils")

local api = vim.api

local M = {}

---@type number|nil
local debounce_timer = nil
local setup_done = false

---Setup autocommands
---@private
function M._setup_autocmds()
  local group = api.nvim_create_augroup("OrgVirtualClocktime", { clear = true })

  -- Main update events - only for org buffers
  api.nvim_create_autocmd(config.options.update_events, {
    group = group,
    pattern = "*.org",
    callback = function(args)
      vim.schedule(function()
        if api.nvim_buf_is_valid(args.buf) then
          display.update(args.buf)
        end
      end)
    end,
  })

  -- Debounced text change events
  api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    pattern = "*.org",
    callback = function(args)
      if debounce_timer then
        debounce_timer:stop()
      end

      debounce_timer = vim.defer_fn(function()
        if api.nvim_buf_is_valid(args.buf) then
          display.update(args.buf)
        end
      end, 500)
    end,
  })
end

---Setup user commands
---@private
function M._setup_commands()
  local function handle_update()
    display.update()
  end

  local function handle_toggle()
    config.options.enabled = not config.options.enabled
    if config.options.enabled then
      display.update_all()
      vim.notify("Clock time display enabled", vim.log.levels.INFO)
    else
      for _, bufnr in ipairs(api.nvim_list_bufs()) do
        if utils.is_valid_org_buffer(bufnr) then
          display.clear(bufnr)
        end
      end
      vim.notify("Clock time display disabled", vim.log.levels.INFO)
    end
  end

  local function handle_clear()
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
      if utils.is_valid_org_buffer(bufnr) then
        display.clear(bufnr)
      end
    end
  end

  local subcommands = {
    update = handle_update,
    toggle = handle_toggle,
    clear = handle_clear,
  }

  local function complete_subcommands(_, _, _)
    return vim.tbl_keys(subcommands)
  end

  api.nvim_create_user_command("OrgVirtualClocktime", function(opts)
    local subcommand = opts.fargs[1]

    if not subcommand then
      vim.notify(
        "Usage: :OrgVirtualClocktime {update|toggle|clear}\n\n"
          .. "  update - Manually update virtual text\n"
          .. "  toggle - Toggle plugin on/off\n"
          .. "  clear  - Clear all virtual text",
        vim.log.levels.WARN
      )
      return
    end

    local handler = subcommands[subcommand]
    if not handler then
      vim.notify(
        "Unknown subcommand: " .. subcommand .. "\nValid subcommands: update, toggle, clear",
        vim.log.levels.ERROR
      )
      return
    end

    handler()
  end, {
    desc = "Manage org-mode clock time virtual text",
    nargs = "?",
    complete = complete_subcommands,
  })
end

---Setup the plugin
---@param opts? OrgVirtualClocktimeConfig
function M.setup(opts)
  -- Prevent double setup
  if setup_done then
    return
  end
  setup_done = true

  config.setup(opts)
  M._setup_autocmds()
  M._setup_commands()

  -- Initial display for already open org buffers
  vim.schedule(function()
    for _, bufnr in ipairs(api.nvim_list_bufs()) do
      if utils.is_valid_org_buffer(bufnr) and api.nvim_buf_is_loaded(bufnr) then
        display.update(bufnr)
      end
    end
  end)
end

-- Export display functions for manual use
M.update = display.update
M.clear = display.clear
M.update_all = display.update_all

return M
