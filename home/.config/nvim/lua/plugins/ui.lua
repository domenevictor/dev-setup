return {
  { -- Same family as the Ghostty theme
    "loctvl842/monokai-pro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("monokai-pro").setup({ filter = "spectrum" })
      vim.cmd.colorscheme("monokai-pro")
    end,
  },

  { -- Shows available keys after you press , (or g, z, ], ...) and wait
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = false },
      spec = {
        { "<leader>a", group = "Claude Code" },
        { "<leader>f", group = "find" },
        { "<leader>h", group = "git hunks" },
      },
    },
  },

  { -- Statusline, text objects, surround, align (replaces lightline/tabular)
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.statusline").setup({ use_icons = false })
      require("mini.ai").setup() -- extra text objects: a( i" af (function) ...
      require("mini.surround").setup() -- sa / sd / sr: add / delete / replace surroundings
      require("mini.align").setup() -- ga / gA: align, e.g. `gaip=` aligns a paragraph on =
    end,
  },
}
