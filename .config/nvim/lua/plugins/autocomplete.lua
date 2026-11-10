return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "super-tab",
    },
    completion = {
      menu = {
        -- Markdown shows the menu only when asked for it. cmp.show() calls
        -- force_auto_show(), so <C-space> still opens it in these buffers.
        auto_show = function(ctx)
          return vim.bo[ctx.bufnr].filetype ~= "markdown"
        end,
      },
    },
  },
}
