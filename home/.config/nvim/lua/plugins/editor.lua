return {
  { -- File tree, pickers (files, grep, buffers…), lazygit. Ctrl-P like before.
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
      lazygit = { enabled = true },
      -- Sidebar file tree (like LazyVim's). Also opens for `nvim .`
      explorer = { enabled = true, replace_netrw = true },
      picker = { enabled = true, icons = { files = { enabled = false } } },
    },
    keys = {
      { "<leader>e", function() Snacks.explorer() end, desc = "File tree" },
      { "<C-p>", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep word under cursor", mode = { "n", "x" } },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Symbols" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics (all)" },
      { "<leader>C", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnostics (buffer)" },
      { "<leader>f.", function() Snacks.picker.resume() end, desc = "Resume last picker" },
      { "<leader>lg", function() Snacks.lazygit() end, desc = "Lazygit" },
    },
  },

  { -- Edit a directory like a buffer (rename/move/delete by editing text).
    -- `-` opens the current file's folder. The file tree handles `nvim .`.
    "stevearc/oil.nvim",
    lazy = false,
    opts = { default_file_explorer = false, columns = {}, view_options = { show_hidden = true } },
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } },
  },

  { -- C-h/j/k/l across nvim splits and tmux panes
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(buf)
        local gs = require("gitsigns")
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buf, desc = desc })
        end
        map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        map("n", "[h", function() gs.nav_hunk("prev") end, "Previous hunk")
        map({ "n", "x" }, "<leader>hs", gs.stage_hunk, "Stage hunk")
        map({ "n", "x" }, "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>hd", gs.diffthis, "Diff against index")
      end,
    },
  },
}
