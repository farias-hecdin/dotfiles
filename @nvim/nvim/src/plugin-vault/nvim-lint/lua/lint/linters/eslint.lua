local a=[[%s*(%d+):(%d+)%s+(%w+)%s+(.+%S)%s+(%S+)]]local b={'lnum','col','severity','message','code'}local c={['error']=vim.diagnostic.severity.ERROR,['warn']=vim.diagnostic.severity.WARN,['warning']=vim.diagnostic.severity.WARN}return require('lint.util').inject_cmd_exe({cmd=function()local d=vim.fn.fnamemodify('./node_modules/.bin/eslint',':p')local e=vim.loop.fs_stat(d)if e then return d end;return'eslint'end,args={'--stdin','--stdin-filename',function()return vim.api.nvim_buf_get_name(0)end},stdin=true,stream='stdout',ignore_exitcode=true,parser=require('lint.parser').from_pattern(a,b,c,{['source']='eslint'})})
