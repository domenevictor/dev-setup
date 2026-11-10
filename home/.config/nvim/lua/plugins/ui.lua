return {
  -- Themes. Default: tokyonight-night. Also: tokyonight-moon, gruvbox-material,
  -- rose-pine-moon. Switch any time with ,fc (live preview). Each has a matching
  -- Ghostty theme; see ~/.config/ghostty/config.
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd.colorscheme("tokyonight-night")
    end,
  },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_enable_italic = 1
    end,
  },
  { "rose-pine/neovim", name = "rose-pine", lazy = false, priority = 1000, opts = { variant = "moon" } }, -- rose-pine-moon

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
