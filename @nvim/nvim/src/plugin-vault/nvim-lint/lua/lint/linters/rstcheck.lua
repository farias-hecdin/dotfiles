local a='([^:]+):(%d+): %((.+)/%d%) (.+)'local b={'file','lnum','severity','message'}local c={INFO=vim.diagnostic.severity.INFO,WARNING=vim.diagnostic.severity.WARN,ERROR=vim.diagnostic.severity.ERROR,SEVERE=vim.diagnostic.severity.ERROR}return{cmd='rstcheck',stdin=false,stream='stderr',args={},ignore_exitcode=true,parser=require('lint.parser').from_pattern(a,b,c,{['source']='rstcheck'})}
