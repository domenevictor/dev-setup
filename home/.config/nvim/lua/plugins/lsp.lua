-- Language servers. Mason installs them into nvim's data dir (:Mason to browse).
-- clangd comes from the system: Xcode Command Line Tools on macOS, apt on Linux.
local tools = {
  -- language servers
  "basedpyright", -- Python types
  "ruff", -- Python lint + format
  "rust-analyzer",
  "vtsls", -- TypeScript / JavaScript
  "lua-language-server",
  "bash-language-server", -- uses shellcheck from Homebrew
  "json-lsp",
  "yaml-language-server",
  -- formatters (see format.lua)
  "prettierd",
}

return {
  { "mason-org/mason.nvim", cmd = "Mason", opts = { ui = { border = "rounded" } } },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsInstallSync", "MasonToolsUpdate" },
    event = "VeryLazy",
    opts = { ensure_installed = tools, run_on_start = true },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "saghen/blink.cmp" },
    config = function()
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim", "Snacks" } }, workspace = { checkThirdParty = false } } },
      })
      require("mason").setup()
      require("mason-lspconfig").setup({ automatic_enable = true }) -- enables every installed server
      if vim.fn.executable("clangd") == 1 then
        vim.lsp.enable("clangd")
      end
    end,
  },

  { -- Completion. <C-y> accepts, <C-n>/<C-p> move, <C-space> opens, <C-e> closes.
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
