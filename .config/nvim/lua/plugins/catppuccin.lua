return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      term_colors = true,
    })
    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}
