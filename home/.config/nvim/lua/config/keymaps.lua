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
map("n", "<leader>x", "<cmd>quit<cr>", { desc = "Close split (quits nvim if it's the last)" })
map("n", "<leader>o", "<cmd>only<cr>", { desc = "Close other splits" })
map("n", "<leader>z", function() Snacks.zen.zoom() end, { desc = "Zoom split (toggle)" })
-- Moving splits around would also move the file tree (,e) out of its place on
-- the left. So after each move, slide the tree's window back to the far left
-- (full height, same width) and share the rest of the space evenly.
local function tree_window()
  local tree = Snacks.picker.get({ source = "explorer" })[1]
  local box = tree and tree.layout and tree.layout.root and tree.layout.root.win
  return (box and vim.api.nvim_win_is_valid(box)) and box or nil
end

local function in_tree()
  local ft = vim.bo.filetype
  return ft == "snacks_layout_box" or ft:match("^snacks_picker") ~= nil
end

local function keep_tree_left(wincmd)
  return function()
    if in_tree() then
      return -- cursor is in the tree itself; nothing sensible to move
    end
    local box = tree_window()
    local width = box and vim.api.nvim_win_get_width(box)
    local ok = pcall(vim.cmd.wincmd, wincmd)
    if not ok then
      -- Vim can only rotate a row/column whose splits aren't split again.
      return vim.notify("Can't rotate this layout (it mixes side-by-side and stacked splits)", vim.log.levels.WARN)
    end
    if box and vim.api.nvim_win_is_valid(box) then
      local win = vim.api.nvim_get_current_win()
      vim.api.nvim_win_call(box, function() vim.cmd.wincmd("H") end)
      vim.api.nvim_win_set_width(box, width)
      vim.api.nvim_set_current_win(win)
      vim.cmd.wincmd("=") -- the tree keeps its width; the rest is shared
    end
  end
end

map("n", "<leader>=", keep_tree_left("="), { desc = "Equalize split sizes" })
map("n", "<leader>H", keep_tree_left("H"), { desc = "Move split to far left (right of the tree)" })
map("n", "<leader>J", keep_tree_left("J"), { desc = "Move split to bottom" })
map("n", "<leader>K", keep_tree_left("K"), { desc = "Move split to top" })
map("n", "<leader>L", keep_tree_left("L"), { desc = "Move split to far right" })
map("n", "<leader>r", keep_tree_left("r"), { desc = "Rotate splits" })

-- Quality of life
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("x", "<", "<gv")
map("x", ">", ">gv")
-- Line diagnostics popup: <C-w>d (built in). ,e is the file tree.
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
-- Also built in (Neovim 0.11+): K hover, grn rename, gra code action,
-- grr references, gri implementation, gO symbols, [d ]d diagnostics, gc comment.
