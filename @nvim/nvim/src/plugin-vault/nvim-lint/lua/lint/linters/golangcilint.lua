local a={error=vim.diagnostic.severity.ERROR,warning=vim.diagnostic.severity.WARN,refactor=vim.diagnostic.severity.INFO,convention=vim.diagnostic.severity.HINT}return{cmd='golangci-lint',append_fname=false,args={'run','--out-format','json',function()return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0),":h")end},stream='stdout',ignore_exitcode=true,parser=function(b,c)if b==''then return{}end;local d=vim.json.decode(b)if d["Issues"]==nil or type(d["Issues"])=='userdata'then return{}end;local e={}for f,g in ipairs(d["Issues"])do local h=vim.api.nvim_buf_get_name(c)local i=vim.fn.getcwd().."/"..g.Pos.Filename;if h==i then local j=a[g.Severity]or a.warning;table.insert(e,{lnum=g.Pos.Line>0 and g.Pos.Line-1 or 0,col=g.Pos.Column>0 and g.Pos.Column-1 or 0,end_lnum=g.Pos.Line>0 and g.Pos.Line-1 or 0,end_col=g.Pos.Column>0 and g.Pos.Column-1 or 0,severity=j,source=g.FromLinter,message=g.Text})end end;return e end}
