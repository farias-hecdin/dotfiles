local a='^<stdin>:(%d+):(%d+): (%w+): (.+)$'local b={'lnum','col','severity','message'}local c={["error"]=vim.diagnostic.severity.ERROR}return{cmd='zig',args={'ast-check'},stdin=true,stream='stderr',ignore_exitcode=true,parser=require('lint.parser').from_pattern(a,b,c,{source='zig ast-check'})}
