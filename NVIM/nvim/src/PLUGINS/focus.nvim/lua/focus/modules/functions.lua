local vim=vim;local a=vim.cmd;local b={}b.focus_enable=function()if vim.g.enabled_focus_resizing==1 then return else vim.g.enabled_focus_resizing=1;require('focus').resize()end end;b.focus_disable=function()if vim.g.enabled_focus_resizing==0 then return else vim.g.enabled_focus_resizing=0;vim.o.winminwidth=0;vim.o.winwidth=20;vim.o.winminheight=1;vim.o.winheight=1;a('wincmd=')end end;b.focus_toggle=function()if vim.g.enabled_focus_resizing==0 then b.focus_enable()return else b.focus_disable()end end;b.focus_maximise=function()vim.o.winwidth=vim.o.columns+1;vim.o.winheight=vim.o.lines+1 end;b.focus_equalise=function()vim.o.winminwidth=0;vim.o.winwidth=20;vim.o.winminheight=1;vim.o.winheight=1;a('wincmd=')end;b.focus_max_or_equal=function()local c=vim.fn.winwidth(vim.api.nvim_get_current_win())if c>vim.o.columns/2 then b.focus_equalise()else b.focus_maximise()end end;return b
