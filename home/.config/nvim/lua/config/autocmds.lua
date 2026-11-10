local group = vim.api.nvim_create_augroup("dev-setup", { clear = true })
local au = function(event, opts)
  opts.group = group
  vim.api.nvim_create_autocmd(event, opts)
end

-- Reload files that agents changed on disk.
au({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

au("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Strip trailing whitespace on save (as before). Formatters also run on save;
-- see lua/plugins/format.lua. Toggle both with :FormatToggle.
au("BufWritePre", {
  callback = function(ev)
    if vim.g.disable_autoformat or vim.b[ev.buf].disable_autoformat then
      return
    end
    if vim.bo[ev.buf].binary or vim.bo[ev.buf].filetype == "diff" then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Reopen files where you left off.
au("BufReadPost", {
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

au("VimResized", { command = "tabdo wincmd =" })

vim.api.nvim_create_user_command("FormatToggle", function(args)
  local scope = args.bang and vim.b or vim.g
  scope.disable_autoformat = not scope.disable_autoformat
  vim.notify(("Format on save %s%s"):format(
    scope.disable_autoformat and "off" or "on", args.bang and " (this buffer)" or ""))
end, { bang = true, desc = "Toggle format-on-save (! = this buffer only)" })
