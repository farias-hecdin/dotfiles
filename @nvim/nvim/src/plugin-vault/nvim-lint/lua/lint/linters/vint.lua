local a={error=vim.diagnostic.severity.ERROR,warning=vim.diagnostic.severity.WARN,style_problem=vim.diagnostic.severity.HINT}return{cmd='vint',stdin=false,args={'--enable-neovim','--style-problem','--json'},ignore_exitcode=true,parser=function(b)local c={}local d=#b>0 and vim.json.decode(b)or{}for e,f in ipairs(d)do local g=f.line_number-1;local h=f.column_number-1;table.insert(c,{source='vint',lnum=g,col=h,end_lnum=g,end_col=h,severity=a[f.severity],message=f.description,user_data={lsp={code=f.policy_name}}})end;return c end}
