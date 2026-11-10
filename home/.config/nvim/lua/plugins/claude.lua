-- Claude Code inside nvim: it sees your open file and selection, and proposes
-- edits as diffs you accept or reject. Keys under ,a
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeAdd", "ClaudeCodeSend" },
    opts = {},
    init = function()
      -- Inside the Claude split you're typing into a terminal, so normal-mode
      -- keys don't apply. Make C-h/j/k/l move between splits/tmux panes from
      -- there too, and go straight back to typing when you return to it.
      local group = vim.api.nvim_create_augroup("dev-setup-claude-term", { clear = true })
      vim.api.nvim_create_autocmd("TermOpen", {
        group = group,
        pattern = "term://*claude*",
        callback = function(ev)
          local nav = { h = "Left", j = "Down", k = "Up", l = "Right" }
          for key, dir in pairs(nav) do
            vim.keymap.set("t", "<C-" .. key .. ">", "<C-\\><C-n><cmd>TmuxNavigate" .. dir .. "<cr>",
              { buffer = ev.buf, desc = "Move to split/pane " .. dir:lower() })
          end
        end,
      })
      vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
        group = group,
        pattern = "term://*claude*",
        command = "startinsert",
      })
    end,
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume a session" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue last session" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add this file" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Send selection" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject diff" },
    },
  },
}
