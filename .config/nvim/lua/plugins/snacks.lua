return {
  "snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        pick = function(cmd, opts)
          return LazyVim.pick(cmd, opts)()
        end,
        header = [[
        ███    ██ ███████  ██████  ██    ██ ██ ███    ███
        ████   ██ ██      ██    ██ ██    ██ ██ ████  ████
        ██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██
        ██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██
        ██   ████ ███████  ██████    ████   ██ ██      ██
        ]],
      },
    },
    picker = {
      enabled = true,
      ui_select = true,  -- Use snacks picker for vim.ui.select
      sources = {
        explorer = {
          auto_close = true,  -- Auto-close explorer after file selection
          jump = { close = true },  -- Close when jumping to a file
          layout = {
            preset = "default",  -- This creates a floating layout
            preview = true,     -- Enable preview
          },
        },
      },
    },
  },
  keys = {
    { "<leader><space>", function() Snacks.picker.buffers() end, desc = "Buffers" },
  },
}
