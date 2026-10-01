return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  opts = {
    default = {
      verbose = false,
    },
  },
  keys = {
    { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
  },
}
