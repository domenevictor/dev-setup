vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

local o = vim.opt

-- UI
o.number = true
o.cursorline = true
o.colorcolumn = "81,121" -- markers after 80 and 120 characters
o.signcolumn = "yes"
o.showmode = false -- the statusline shows it
o.laststatus = 3 -- one statusline for all splits
o.fillchars = { vert = "│", eob = " ", fold = " " }
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.wrap = true
o.linebreak = true
o.breakindent = true
o.scrolloff = 3
o.splitright = true
o.splitbelow = true
o.mouse = "a"
o.confirm = true

-- Search
o.ignorecase = true
o.smartcase = true
o.inccommand = "split" -- live preview of :s

-- Editing
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.undofile = true -- persistent undo replaces the old backup files
o.updatetime = 250
o.timeoutlen = 400
o.autoread = true -- pick up files changed by agents (see autocmds)

-- Folds: treesitter-based, all open by default
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
o.foldlevelstart = 99

-- Clipboard: yanks go to the system clipboard. Over SSH/mosh, use OSC 52 so
-- copies reach the clipboard of the laptop or phone you're connecting from.
if os.getenv("SSH_TTY") or os.getenv("SSH_CONNECTION") then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
vim.schedule(function()
  o.clipboard = "unnamedplus"
end)

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { spacing = 2, source = "if_many" },
  float = { border = "rounded", source = "if_many" },
  signs = { text = { "E", "W", "I", "H" } },
})
