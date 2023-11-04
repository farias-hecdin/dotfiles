local a=require("nvim-lsp-extras.treesitter_hover.text")local b=require("nvim-lsp-extras.treesitter_hover.markdown")if vim.lsp.util._normalize_markdown then require("nvim-lsp-extras.treesitter_hover.hack")end;local c={}c.ns=vim.api.nvim_create_namespace("lsp_markdown_highlight")local function d(e,f)if package.loaded[e]then return f(package.loaded[e])end;package.preload[e]=function()package.preload[e]=nil;for g,h in pairs(package.loaders)do local i=h(e)if type(i)=="function"then local j=i()f(j)return j end end end end;local function k(l)for g,m in ipairs(l)do if m~=""then return l end end;return{}end;function c.setup()d("cmp.entry",function(j)j.get_documentation=function(self)local n=self:get_completion_item()local o=n.documentation and b.format_markdown(n.documentation)or{}local i=table.concat(o,"\n")if n.detail and not i:find(n.detail,1,true)then local p=self.context.filetype;local q=string.find(p,"%.")if q~=nil then p=string.sub(p,0,q-1)end;i=("```%s\n%s\n```\n%s"):format(p,vim.trim(n.detail),i)end;return vim.split(i,"\n")end end)vim.lsp.util.convert_input_to_markdown_lines=function(r,l)l=l or{}local i=b.format_markdown(r)vim.list_extend(l,i)return k(l)end;vim.lsp.util.stylize_markdown=function(s,l,g)vim.api.nvim_buf_clear_namespace(s,c.ns,0,-1)local t=table.concat(l,"\n")local u=a.format(t)a.render(u,s,c.ns)b.set_keymap(s)return vim.api.nvim_buf_get_lines(s,0,-1,false)end end;return c
