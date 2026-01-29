# org-virtual-clocktime.nvim

Sum logbook clocktime with virtual text:

```org
** Sample header
   :LOGBOOK: => 0:41
   CLOCK: [2026-01-25 Sun 15:33]--[2026-01-25 Sun 15:37] => 0:04
   CLOCK: [2026-01-25 Sun 14:53]--[2026-01-25 Sun 15:30] => 0:37
   :END:
```

## Installation

In this example, we're using [lazy.nvim](https://github.com/folke/lazy.nvim) as our package manager and including `org-journal.nvim` as a dependency of `nvim-orgmode`:

```lua
{
  "nvim-orgmode/orgmode",
  ft = { "org" },
  cmd = "Org",
  dependencies = {
    {
      "hugginsio/org-virtual-clocktime.nvim"
    }
  }
}
```

## Configuration

```lua
{
  hl_group = "@comment",
  update_events = { "BufEnter", "BufWritePost", "InsertLeave" },
  format = function(minutes)
    local hours = math.floor(minutes / 60)
    local mins = minutes % 60
    return string.format("=> %d:%02d", hours, mins)
  end,
  enabled = true,
}
```

Override any of these options by passing them to `setup()`.

## Usage

Within an `orgmode` buffer, clocktime sums are automatically calculated and displayed. However, a command is available to control the displayed text:

- `:OrgVirtualClocktime update` - Manually update virtual text
- `:OrgVirtualClocktime toggle` - Toggle plugin on/off
- `:OrgVirtualClocktime clear` - Clear all virtual text
