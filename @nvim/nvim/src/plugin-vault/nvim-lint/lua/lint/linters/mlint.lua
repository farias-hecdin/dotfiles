local a="L (%d+) %(C (%d+)[-]?([%d]*)%): (.-): (.-): (.*)"local b={"lnum","col","end_col","code","severity","message"}local c={ML2=vim.diagnostic.severity.ERROR,ML3=vim.diagnostic.severity.ERROR,ML4=vim.diagnostic.severity.ERROR,ML1=vim.diagnostic.severity.WARN,ML0=vim.diagnostic.severity.INFO,ML5=vim.diagnostic.severity.HINT}return{cmd="mlint",stdin=false,stream="stderr",args={"-cyc","-id","-severity"},ignore_exitcode=true,parser=require("lint.parser").from_pattern(a,b,c,{["source"]="mlint"})}
