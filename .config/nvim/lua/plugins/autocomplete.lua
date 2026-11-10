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
      -- The inline preview follows the menu rather than appearing on its own,
      -- so buffers with no automatic menu stay quiet until <C-space>. LazyVim's
      -- blink extra enables ghost text from vim.g.ai_cmp.
      ghost_text = {
        show_without_menu = false,
      },
    },
  },
}
