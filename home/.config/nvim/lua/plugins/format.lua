-- Format on save (:FormatToggle to turn off, :FormatToggle! for one buffer).
-- ,k formats by hand, like the old :ClangFormat mapping.
local web = { "prettierd", "prettier", stop_after_first = true }

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>k",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "x" },
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        javascript = web,
        typescript = web,
        javascriptreact = web,
        typescriptreact = web,
        json = web,
        yaml = web,
        markdown = web,
        css = web,
        html = web,
      },
      format_on_save = function(buf)
        if vim.g.disable_autoformat or vim.b[buf].disable_autoformat then
          return
        end
        return { timeout_ms = 1500, lsp_format = "fallback" }
      end,
    },
  },
}
