local a="[^:]+:(%d+):(%d+):([^%.]+%.?)%s%(([%a-]+)%)%s?%(?(%a*)%)?"local b={'lnum','col','message','code','severity'}local c={['']=vim.diagnostic.severity.ERROR,['warning']=vim.diagnostic.severity.WARN}return{cmd='standard',stdin=true,args={"--stdin"},ignore_exitcode=true,parser=require('lint.parser').from_pattern(a,b,c,{['source']='standardjs'},{})}
