return {
  "folke/persistence.nvim",
  -- Registered from `init` because LazyVim loads autocmds.lua on VeryLazy,
  -- after VimEnter has fired. The snacks dashboard sets itself up on UIEnter,
  -- which follows VimEnter, and skips opening once buffer 1 is no longer the
  -- empty unnamed buffer, so the dashboard still appears when no session exists.
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("restore_session", { clear = true }),
      nested = true,
      callback = function()
        if vim.fn.argc(-1) > 0 then
          return
        end
        local ui = vim.api.nvim_list_uis()[1]
        -- Headless runs and piped stdin (`cmd | nvim -`) are not editing sessions.
        if not ui or (ui.stdout_tty and not ui.stdin_tty) then
          return
        end
        require("persistence").load()
      end,
    })
  end,
}
