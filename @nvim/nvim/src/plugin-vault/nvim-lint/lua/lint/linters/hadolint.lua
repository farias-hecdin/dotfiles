local a={error=vim.diagnostic.severity.ERROR,warning=vim.diagnostic.severity.WARN,info=vim.diagnostic.severity.INFO,style=vim.diagnostic.severity.HINT}return{cmd='hadolint',stdin=true,stream='stdout',ignore_exitcode=true,args={'-f','json','-'},parser=function(b)local c=vim.json.decode(b)local d={}for e,f in pairs(c or{})do table.insert(d,{lnum=f.line-1,col=f.column,end_lnum=f.line-1,end_col=f.column,severity=assert(a[f.level],'missing mapping for severity '..f.level),message=f.message})end;return d end}
