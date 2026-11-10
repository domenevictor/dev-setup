-- Plugin keys live next to each plugin in lua/plugins/. Press , and wait to
-- see everything (which-key).
local map = vim.keymap.set

-- From the old .vimrc
map("i", "jk", "<Esc>")
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x", "o" }, "B", "^", { desc = "Start of line" })
map({ "n", "x", "o" }, "E", "$", { desc = "End of line" })
map("n", "gV", "`[v`]", { desc = "Select last pasted/changed text" })
map({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map({ "n", "x" }, "<leader>p", '"+p', { desc = "Paste from clipboard" })
map("n", "<leader>w", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, { desc = "Strip trailing whitespace" })

-- Splits: same letters as tmux (prefix | and -, prefix z). C-h/j/k/l move.
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split below" })
map("n", "<leader>x", "<cmd>close<cr>", { desc = "Close split" })
map("n", "<leader>o", "<cmd>only<cr>", { desc = "Close other splits" })
map("n", "<leader>z", function() Snacks.zen.zoom() end, { desc = "Zoom split (toggle)" })
map("n", "<leader>=", "<C-w>=", { desc = "Equalize split sizes" })
map("n", "<leader>H", "<C-w>H", { desc = "Move split to far left" })
map("n", "<leader>J", "<C-w>J", { desc = "Move split to bottom" })
map("n", "<leader>K", "<C-w>K", { desc = "Move split to top" })
map("n", "<leader>L", "<C-w>L", { desc = "Move split to far right" })
map("n", "<leader>r", "<C-w>r", { desc = "Rotate splits" })

-- Quality of life
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("x", "<", "<gv")
map("x", ">", ">gv")
-- Line diagnostics popup: <C-w>d (built in). ,e is the file tree.
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
-- Also built in (Neovim 0.11+): K hover, grn rename, gra code action,
-- grr references, gri implementation, gO symbols, [d ]d diagnostics, gc comment.
