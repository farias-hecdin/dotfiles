local a=require"fzf-lua.path"local b=require"fzf-lua.shell"local c=require"fzf-lua.utils"local d=require"fzf-lua.class"local e=vim.api;local f=vim.loop;local g=vim.fn;local h,i,j;local k={}k.base=d:extend()function k.base:new(l,m,n)local function o(p,q)if p~=nil then return p else return q end end;l=l or{}self.type="builtin"self.opts=m;self.win=n;self.delay=self.win.winopts.preview.delay or 100;self.title=self.win.winopts.preview.title;self.title_align=self.win.winopts.preview.title_align;self.winopts=self.win.winopts.preview.winopts;self.syntax=o(l.syntax,true)self.syntax_delay=o(l.syntax_delay,0)self.syntax_limit_b=o(l.syntax_limit_b,1024*1024)self.syntax_limit_l=o(l.syntax_limit_l,0)self.limit_b=o(l.limit_b,1024*1024*10)self.treesitter=l.treesitter or{}self.toggle_behavior=l.toggle_behavior;self.backups={}if l.extensions then self.extensions={}for r,s in pairs(l.extensions)do self.extensions[r:lower()]=s end end;local t={["crop"]="crop",["distort"]="distort",["contain"]="contain",["fit_contain"]="fit_contain",["cover"]="cover",["forced_cover"]="forced_cover"}self.ueberzug_scaler=l.ueberzug_scaler and t[l.ueberzug_scaler]if l.ueberzug_scaler and not self.ueberzug_scaler then c.warn(("Invalid ueberzug image scaler '%s', option will be omitted."):format(l.ueberzug_scaler))end;self.cached_buffers={}self.listed_buffers=(function()local u={}vim.tbl_map(function(v)if vim.fn.buflisted(v)==1 then u[tostring(v)]=true end end,vim.api.nvim_list_bufs())return u end)()return self end;function k.base:close()self:restore_winopts(self.win.preview_winid)self:clear_preview_buf()self:clear_cached_buffers()self.backups={}end;function k.base:gen_winopts()local w={wrap=self.win.preview_wrap}return vim.tbl_extend("keep",w,self.winopts)end;function k.base:backup_winopts(x)if not x or not e.nvim_win_is_valid(x)then return end;for y,_ in pairs(self:gen_winopts())do if c.nvim_has_option(y)then self.backups[y]=e.nvim_win_get_option(x,y)end end end;function k.base:restore_winopts(x)if not x or not e.nvim_win_is_valid(x)then return end;for y,z in pairs(self.backups)do pcall(vim.api.nvim_win_set_option,x,y,z)end end;function k.base:set_winopts(x)if self.do_not_set_winopts then return end;if not x or not e.nvim_win_is_valid(x)then return end;for y,s in pairs(self:gen_winopts())do if c.nvim_has_option(y)then e.nvim_win_set_option(x,y,s)end end end;function k.base:preview_is_terminal()if not self.win or not self.win:validate_preview()then return end;return vim.fn.getwininfo(self.win.preview_winid)[1].terminal==1 end;function k.base:get_tmp_buffer()local A=e.nvim_create_buf(false,true)e.nvim_buf_set_option(A,"bufhidden","wipe")return A end;function k.base:set_preview_buf(B)if not self.win or not self.win:validate_preview()then return end;c.win_set_buf_noautocmd(self.win.preview_winid,B)self.preview_bufnr=B;self:set_winopts(self.win.preview_winid)end;local function C(D)if tonumber(D)and vim.api.nvim_buf_is_valid(D)then e.nvim_buf_call(D,function()vim.cmd([[delm \"]])end)vim.api.nvim_buf_delete(D,{force=true})end end;function k.base:cache_buffer(D,E,F)if not E then return end;if not D then return end;local G=self.cached_buffers[E]if G then if G.bufnr==D then return else if not G.do_not_unload then C(G.bufnr)end end end;self.cached_buffers[E]={bufnr=D,do_not_unload=F}e.nvim_buf_set_option(D,"bufhidden","hide")end;function k.base:clear_cached_buffers()for _,H in pairs(self.cached_buffers)do if not H.do_not_unload then C(H.bufnr)end end;self.cached_buffers={}end;function k.base:clear_preview_buf(B)local I=nil;if(self.win and self.win._reuse or B)and self.win and self.win.preview_winid and tonumber(self.win.preview_winid)>0 and e.nvim_win_is_valid(self.win.preview_winid)then I=self:get_tmp_buffer()c.win_set_buf_noautocmd(self.win.preview_winid,I)end;if not self.do_not_unload then C(self.preview_bufnr)end;self.preview_bufnr=nil;self.loaded_entry=nil;return I end;function k.base:display_last_entry()self:display_entry(self.last_entry)end;function k.base:display_entry(J)if not J then return else self.last_entry=J end;if not self.win or not self.win:validate_preview()then return end;if rawequal(next(self.backups),nil)then self:backup_winopts(self.win.src_winid)end;local K=e.nvim_win_get_buf(self.win.preview_winid)assert(not self.preview_bufnr or K==self.preview_bufnr)if self.should_clear_preview and self:should_clear_preview(J)then self.preview_bufnr=self:clear_preview_buf(true)end;local L=function(M)if not self.win or not self.win:validate_preview()then return end;self:populate_preview_buf(M)if not self.do_not_set_winopts then self:set_winopts(self.win.preview_winid)else self.win:set_style_minimal(self.win.preview_winid)end;self.win:reset_win_highlights(self.win.preview_winid)end;if tonumber(self.delay)>0 then if not self._entry_count then self._entry_count=1 else self._entry_count=self._entry_count+1 end;local N=self._entry_count;vim.defer_fn(function()if self._entry_count==N then L(J)end end,self.delay)else L(J)end end;function k.base:cmdline(_)local O=b.raw_action(function(P,_,_)self:display_entry(P[1])return""end,"{}",self.opts.debug)return O end;function k.base:preview_window(_)if self.win and not self.win.winopts.split then return"nohidden:right:0"else return nil end end;function k.base:scroll(Q)local R=self.win.preview_winid;if R<0 or not Q then return end;if not e.nvim_win_is_valid(R)then return end;if Q==0 then pcall(vim.api.nvim_win_call,R,function()e.nvim_win_set_cursor(0,{1,0})if self.orig_pos then e.nvim_win_set_cursor(0,self.orig_pos)end;c.zz()end)elseif not self:preview_is_terminal()then local S=("%c"):format(c._if(Q>0,0x04,0x15))pcall(vim.api.nvim_win_call,R,function()vim.cmd([[norm! ]]..S)c.zz()end)else local S=Q>0 and"<C-d>"or"<C-u>"vim.cmd("stopinsert")c.feed_keys_termcodes((":noa lua vim.api.nvim_win_call("..[[%d, function() vim.cmd("norm! <C-v>%s") vim.cmd("startinsert") end)<CR>]]):format(tonumber(R),S))end;if self.orig_pos and self.winopts.cursorline then local T=vim.fn.getwininfo(R)if T and T[1]and self.orig_pos[1]>=T[1].topline and self.orig_pos[1]<=T[1].botline then vim.api.nvim_win_set_cursor(R,self.orig_pos)vim.api.nvim_win_set_option(R,"cursorline",true)else vim.api.nvim_win_set_option(R,"cursorline",false)end end;self.win:update_scrollbar()end;k.buffer_or_file=k.base:extend()function k.buffer_or_file:new(l,m,n)k.buffer_or_file.super.new(self,l,m,n)return self end;function k.buffer_or_file:close()self:restore_winopts(self.win.preview_winid)self:clear_preview_buf()self:clear_cached_buffers()self:stop_ueberzug()self.backups={}end;function k.buffer_or_file:parse_entry(J)local U=a.entry_to_file(J,self.opts)return U end;function k.buffer_or_file:should_clear_preview(_)return false end;function k.buffer_or_file:should_load_buffer(U)if not self.loaded_entry then return true end;if type(U)=="string"then U=self:parse_entry(U)end;if U.bufnr and U.bufnr==self.loaded_entry.bufnr or not U.bufnr and U.path and U.path==self.loaded_entry.path then return false end;return true end;function k.buffer_or_file:start_ueberzug()if self._ueberzug_fifo then return self._ueberzug_fifo end;local V=("fzf-lua-%d-ueberzug"):format(vim.fn.getpid())self._ueberzug_fifo=vim.fn.systemlist({"mktemp","--dry-run","--suffix",V})[1]vim.fn.system({"mkfifo",self._ueberzug_fifo})self._ueberzug_job=vim.fn.jobstart({"sh","-c",("tail --follow %s | ueberzug layer --parser json"):format(vim.fn.shellescape(self._ueberzug_fifo))},{on_exit=function(_,W,_)if W~=0 and W~=143 then c.warn(("ueberzug exited with error %d"):format(W)..", run ':messages' to see the detailed error.")end end,on_stderr=function(_,X,_)for _,Y in ipairs(X or{})do if#Y>0 then c.info(Y)end end;if self.preview_bufnr and self.preview_bufnr>0 and vim.api.nvim_buf_is_valid(self.preview_bufnr)then local Z=vim.api.nvim_buf_get_lines(self.preview_bufnr,0,-1,false)for _,Y in ipairs(X or{})do table.insert(Z,Y)end;vim.api.nvim_buf_set_lines(self.preview_bufnr,0,-1,false,Z)end end})self._ueberzug_pid=vim.fn.jobpid(self._ueberzug_job)return self._ueberzug_fifo end;function k.buffer_or_file:stop_ueberzug()if self._ueberzug_job then vim.fn.jobstop(self._ueberzug_job)if type(f.os_getpriority(self._ueberzug_pid))=="number"then f.kill(self._ueberzug_pid,9)end;self._ueberzug_job=nil;self._ueberzug_pid=nil end;if self._ueberzug_fifo and f.fs_stat(self._ueberzug_fifo)then vim.fn.delete(self._ueberzug_fifo)self._ueberzug_fifo=nil end end;function k.buffer_or_file:populate_terminal_cmd(a0,a1,U)if not a1 then return end;a1=type(a1)=="table"and c.deepcopy(a1)or{a1}if not a1[1]or vim.fn.executable(a1[1])~=1 then return false end;self.loaded_entry=nil;self.do_not_cache=true;self.do_not_set_winopts=true;self.clear_on_redraw=true;self:set_preview_buf(a0)if a1[1]:match("ueberzug")then local V=self:start_ueberzug()if not V then return end;local a2=vim.api.nvim_win_get_config(self.win.preview_winid)local a3=vim.api.nvim_win_get_position(self.win.preview_winid)local a4={action="add",identifier="preview",x=a3[2],y=a3[1],width=a2.width,height=a2.height,scaler=self.ueberzug_scaler,path=a.starts_with_separator(U.path)and U.path or a.join({self.opts.cwd or f.cwd(),U.path})}local a5=vim.json.encode(a4)local a6=f.fs_open(self._ueberzug_fifo,"a",-1)if a6 then f.fs_write(a6,a5 .."\n",nil,function(_)f.fs_close(a6)end)end else table.insert(a1,U.path)vim.bo[a0].modifiable=true;vim.api.nvim_buf_call(a0,function()self._job_id=vim.fn.termopen(a1,{cwd=self.opts.cwd,on_exit=function()if self._job_id then self:preview_buf_post(U)self._job_id=nil end end})end)end;self:preview_buf_post(U)return true end;function k.buffer_or_file:populate_from_cache(U)local E=U and(U.path or U.uri)local G=self.cached_buffers[E]if G and vim.api.nvim_buf_is_valid(G.bufnr)then self:set_preview_buf(G.bufnr)self:preview_buf_post(U)return true end;return false end;function k.buffer_or_file:populate_preview_buf(J)if not self.win or not self.win:validate_preview()then return end;local U=self:parse_entry(J)if vim.tbl_isempty(U)then return end;if not self:should_load_buffer(U)then self:preview_buf_post(U)return end;self:stop_ueberzug()if self._job_id and self._job_id>0 then vim.fn.jobstop(self._job_id)self._job_id=nil end;self.clear_on_redraw=false;self.do_not_cache=false;self.do_not_unload=false;self.do_not_set_winopts=U.terminal;if self:populate_from_cache(U)then return elseif U.bufnr and e.nvim_buf_is_loaded(U.bufnr)then U.filetype=vim.api.nvim_buf_get_option(U.bufnr,"filetype")local Z=vim.api.nvim_buf_get_lines(U.bufnr,0,-1,false)local a0=self:get_tmp_buffer()vim.api.nvim_buf_set_lines(a0,0,-1,false,Z)self:set_preview_buf(a0)self:preview_buf_post(U)elseif U.uri then pcall(vim.api.nvim_win_call,self.win.preview_winid,function()vim.lsp.util.jump_to_location(U,"utf-16",false)self.preview_bufnr=vim.api.nvim_get_current_buf()if self.listed_buffers[tostring(self.preview_bufnr)]then self.do_not_unload=true end end)self:preview_buf_post(U)else if U.bufnr and vim.api.nvim_buf_is_valid(U.bufnr)then U.path=a.relative(vim.api.nvim_buf_get_name(U.bufnr),vim.loop.cwd())end;assert(U.path)if self:populate_from_cache(U)then return end;local a0=self:get_tmp_buffer()if self.extensions and not vim.tbl_isempty(self.extensions)then local a7=a.extension(U.path)local a1=a7 and self.extensions[a7:lower()]if a1 and self:populate_terminal_cmd(a0,a1,U)then return end end;do local Z=nil;local a8=vim.loop.fs_stat(U.path)if not U.path or not a8 then Z={string.format("Unable to stat file %s",U.path)}elseif a8.size>0 and c.perl_file_is_binary(U.path)then Z={"Preview is not supported for binary files."}elseif tonumber(self.limit_b)>0 and a8.size>self.limit_b then Z={("Preview file size limit (>%dMB) reached, file size %dMB."):format(self.limit_b/(1024*1024),a8.size/(1024*1024))}end;if Z then vim.api.nvim_buf_set_lines(a0,0,-1,false,Z)self:set_preview_buf(a0)self:preview_buf_post(U)return end end;c.read_file_async(U.path,vim.schedule_wrap(function(X)local Z=vim.split(X,"[\r]?\n")if X:sub(#X,#X)=="\n"or X:sub(#X-1,#X)=="\r\n"then table.remove(Z)end;vim.api.nvim_buf_set_lines(a0,0,-1,false,Z)self:set_preview_buf(a0)self:preview_buf_post(U)end))end end;local a9=function(D,aa)if not h then h,_=pcall(require,"nvim-treesitter")if h then _,i=pcall(require,"nvim-treesitter.configs")_,j=pcall(require,"nvim-treesitter.parsers")end end;if not h or not aa or aa==""then return false end;local ab=j.ft_to_lang(aa)if not i.is_enabled("highlight",ab,D)then return false end;local ac=i.get_module"highlight"vim.treesitter.highlighter.new(j.get_parser(D,ab))local ad=type(ac.additional_vim_regex_highlighting)=="table"if ac.additional_vim_regex_highlighting and(not ad or vim.tbl_contains(ac.additional_vim_regex_highlighting,ab))then vim.api.nvim_buf_set_option(D,"syntax",aa)end;return true end;function k.buffer_or_file:do_syntax(U)if not self.preview_bufnr then return end;if not U or not U.path then return end;local D=self.preview_bufnr;local R=self.win.preview_winid;if e.nvim_buf_is_valid(D)and vim.bo[D].filetype==""then if g.bufwinid(D)==R then local ae=e.nvim_buf_line_count(D)local af=e.nvim_buf_get_offset(D,ae)local ag=0;if self.syntax_limit_l>0 and ae>self.syntax_limit_l then ag=1 end;if self.syntax_limit_b>0 and af>self.syntax_limit_b then ag=2 end;if ag>0 then c.info(string.format("syntax disabled for '%s' (%s), consider increasing '%s(%d)'",U.path,c._if(ag==1,("%d lines"):format(ae),("%db"):format(af)),c._if(ag==1,"syntax_limit_l","syntax_limit_b"),c._if(ag==1,self.syntax_limit_l,self.syntax_limit_b)))end;if ag==0 then local ah=vim.fn.has("nvim-0.8")==0;if not ah then ah=(function()local aa=vim.filetype.match({buf=D,filename=U.path})if type(aa)~="string"then return true end;local ai=(function()if not self.treesitter or self.treesitter.enable==false or self.treesitter.disable==true or type(self.treesitter.enable)=="table"and not vim.tbl_contains(self.treesitter.enable,aa)or type(self.treesitter.disable)=="table"and vim.tbl_contains(self.treesitter.disable,aa)then return false end;return true end)()local aj;if ai then aj=a9(D,aa)end;if not ai or not aj then pcall(vim.api.nvim_buf_set_option,D,"syntax",aa)end end)()end;if ah then if U.filetype=="help"then pcall(e.nvim_buf_set_option,D,"filetype",U.filetype)else local ak=a.join({tostring(D),U.path})pcall(e.nvim_buf_set_name,D,ak)end;local al,_=pcall(e.nvim_buf_call,D,function()vim.cmd("filetype detect")end)if not al then c.warn(("syntax highlighting failed for filetype '%s', "):format(U.path and a.extension(U.path)or"<null>").."open the file and run ':filetype detect' for more info.")end end end end end end;function k.buffer_or_file:set_cursor_hl(U)pcall(vim.api.nvim_win_call,self.win.preview_winid,function()local am,an=tonumber(U.line),tonumber(U.col)local ao=U.pattern or U.text;if not am or am<1 then e.nvim_win_set_cursor(0,{1,0})if ao~=""then g.search(ao,"c")end else if not pcall(e.nvim_win_set_cursor,0,{am,math.max(0,an-1)})then return end end;c.zz()self.orig_pos=e.nvim_win_get_cursor(0)g.clearmatches()if self.win.winopts.__hl.cursor and not(am<=1 and an<=1)then g.matchaddpos(self.win.winopts.__hl.cursor,{{am,math.max(1,an)}},11)end end)end;function k.buffer_or_file:update_border(U)if self.title then local ap=U.path;if ap then if self.opts.cwd then ap=a.relative(U.path,self.opts.cwd)end;ap=a.HOME_to_tilde(ap)end;local aq=(" %s "):format(ap or U.uri)if U.bufnr then local ar=("buf %d:"):format(U.bufnr)aq=(" %s %s "):format(ar,U.path)end;self.win:update_title(aq)end;self.win:update_scrollbar()end;function k.buffer_or_file:preview_buf_post(U)if not self.win or not self.win:validate_preview()then return end;if not self:preview_is_terminal()then self:set_cursor_hl(U)if self.syntax then if self.syntax_delay>0 then vim.defer_fn(function()self:do_syntax(U)end,self.syntax_delay)else self:do_syntax(U)end end end;self:update_border(U)self.loaded_entry=U;if not self.do_not_cache then local E=self.loaded_entry and(self.loaded_entry.path or self.loaded_entry.uri)self:cache_buffer(self.preview_bufnr,E,self.do_not_unload)end end;k.help_tags=k.base:extend()function k.help_tags:should_clear_preview(_)return false end;function k.help_tags:new(l,m,n)k.help_tags.super.new(self,l,m,n)self.split=l.split;self.help_cmd=l.help_cmd or"help"self.filetype="help"self.do_not_unload=true;self:init_help_win()return self end;function k.help_tags:gen_winopts()local w={wrap=self.win.preview_wrap,number=false}return vim.tbl_extend("keep",w,self.winopts)end;function k.help_tags:exec_cmd(as)as=as or""vim.cmd(("noauto %s %s %s"):format(self.split,self.help_cmd,as))end;function k.help_tags:parse_entry(J)return J:match("[^%s]+")end;local function at()for _,au in ipairs(vim.api.nvim_tabpage_list_wins(0))do local D=vim.api.nvim_win_get_buf(au)local av=vim.fn.getbufinfo(D)[1]if av.variables and av.variables.current_syntax=="help"then return D,au end end;return nil,nil end;function k.help_tags:init_help_win(as)if not self.split or self.split~="topleft"and self.split~="botright"then self.split="botright"end;local aw=e.nvim_get_current_win()self.help_bufnr,self.help_winid=at()if not self.help_bufnr then self:exec_cmd(as)self.help_bufnr=e.nvim_get_current_buf()self.help_winid=e.nvim_get_current_win()pcall(vim.api.nvim_win_set_height,0,0)pcall(vim.api.nvim_win_set_width,0,0)e.nvim_set_current_win(aw)end end;function k.help_tags:populate_preview_buf(J)local U=self:parse_entry(J)pcall(vim.api.nvim_win_call,self.help_winid,function()self.prev_help_bufnr=e.nvim_get_current_buf()self:exec_cmd(U)vim.api.nvim_buf_set_option(0,"filetype",self.filetype)self.preview_bufnr=e.nvim_get_current_buf()self.orig_pos=e.nvim_win_get_cursor(0)end)c.win_set_buf_noautocmd(self.win.preview_winid,self.preview_bufnr)e.nvim_win_set_cursor(self.win.preview_winid,self.orig_pos)self.win:update_scrollbar()if self.prev_help_bufnr~=self.preview_bufnr and e.nvim_buf_is_valid(self.prev_help_bufnr)then e.nvim_buf_delete(self.prev_help_bufnr,{force=true})self.prev_help_bufnr=self.preview_bufnr end end;function k.help_tags:win_leave()if self.help_winid and vim.api.nvim_win_is_valid(self.help_winid)then c.nvim_win_close(self.help_winid,true)end;if self.help_bufnr and vim.api.nvim_buf_is_valid(self.help_bufnr)then vim.api.nvim_buf_delete(self.help_bufnr,{force=true})end;if self.prev_help_bufnr and vim.api.nvim_buf_is_valid(self.prev_help_bufnr)then vim.api.nvim_buf_delete(self.prev_help_bufnr,{force=true})end;self.help_winid=nil;self.help_bufnr=nil;self.prev_help_bufnr=nil end;k.help_file=k.buffer_or_file:extend()function k.help_file:new(l,m,n)k.help_file.super.new(self,l,m,n)return self end;function k.help_file:parse_entry(J)local ax,ay=J:match("(.*)%s+(.*)$")return{htag=ax,hregex=([[\V*%s*]]):format(ax:gsub([[\]],[[\\]])),path=ay,filetype="help"}end;function k.help_file:gen_winopts()local w={wrap=self.win.preview_wrap,number=false}return vim.tbl_extend("keep",w,self.winopts)end;function k.help_file:set_cursor_hl(U)pcall(e.nvim_win_call,self.win.preview_winid,function()e.nvim_win_set_cursor(0,{1,0})g.clearmatches()g.search(U.hregex,"W")if self.win.winopts.__hl.search then g.matchadd(self.win.winopts.__hl.search,U.hregex)end;self.orig_pos=e.nvim_win_get_cursor(0)c.zz()end)end;k.man_pages=k.base:extend()function k.man_pages:should_clear_preview(_)return false end;function k.man_pages:gen_winopts()local w={wrap=self.win.preview_wrap,number=false}return vim.tbl_extend("keep",w,self.winopts)end;function k.man_pages:new(l,m,n)k.man_pages.super.new(self,l,m,n)self.filetype="man"self.cmd=l.cmd or"man -c %s | col -bx"return self end;function k.man_pages:parse_entry(J)return J:match("[^[,( ]+")end;function k.man_pages:populate_preview_buf(J)local U=self:parse_entry(J)local a1=self.cmd:format(U)if type(a1)=="string"then a1={"sh","-c",a1}end;local az,_=c.io_systemlist(a1)local a0=self:get_tmp_buffer()vim.api.nvim_buf_set_lines(a0,0,-1,false,az)vim.api.nvim_buf_set_option(a0,"filetype",self.filetype)self:set_preview_buf(a0)self.win:update_scrollbar()end;k.marks=k.buffer_or_file:extend()function k.marks:new(l,m,n)k.marks.super.new(self,l,m,n)return self end;function k.marks:parse_entry(J)local D=nil;local aA,am,an,ap=J:match("(.)%s+(%d+)%s+(%d+)%s+(.*)")local aB=vim.api.nvim_buf_get_mark(self.win.src_bufnr,aA)if aB and aB[1]>0 and aB[1]==tonumber(am)then D=self.win.src_bufnr;ap=e.nvim_buf_get_name(D)end;if ap and#ap>0 then local al,aC=pcall(vim.fn.expand,ap)if not al then ap=""else ap=aC end;ap=a.relative(ap,vim.loop.cwd())end;return{bufnr=D,path=ap,line=tonumber(am)or 1,col=tonumber(an)or 1}end;k.jumps=k.buffer_or_file:extend()function k.jumps:new(l,m,n)k.jumps.super.new(self,l,m,n)return self end;function k.jumps:parse_entry(J)local D=nil;local _,am,an,ap=J:match("(%d+)%s+(%d+)%s+(%d+)%s+(.*)")if ap then local al,aC=pcall(vim.fn.expand,ap)if al then ap=a.relative(aC,vim.loop.cwd())end;if not vim.loop.fs_stat(ap)then D=self.win.src_bufnr;ap=vim.api.nvim_buf_get_name(self.win.src_bufnr)end end;return{bufnr=D,path=ap,line=tonumber(am)or 1,col=tonumber(an)+1 or 1}end;k.tags=k.buffer_or_file:extend()function k.tags:new(l,m,n)k.tags.super.new(self,l,m,n)return self end;function k.tags:parse_entry(J)local U=self.super.parse_entry(self,J)U.ctag=a.entry_to_ctag(J)return U end;function k.tags:set_cursor_hl(U)pcall(e.nvim_win_call,self.win.preview_winid,function()e.nvim_win_set_cursor(0,{1,0})g.clearmatches()g.search(U.ctag,"W")if self.win.winopts.__hl.search then g.matchadd(self.win.winopts.__hl.search,U.ctag)end;self.orig_pos=e.nvim_win_get_cursor(0)c.zz()end)end;k.highlights=k.base:extend()function k.highlights:should_clear_preview(_)return false end;function k.highlights:gen_winopts()local w={wrap=self.win.preview_wrap,number=false}return vim.tbl_extend("keep",w,self.winopts)end;function k.highlights:new(l,m,n)k.highlights.super.new(self,l,m,n)self.ns_previewer=vim.api.nvim_create_namespace("fzf-lua.previewer.hl")return self end;function k.highlights:close()k.highlights.super.close(self)self.tmpbuf=nil end;function k.highlights:populate_preview_buf(J)if not self.tmpbuf then local az=vim.split(vim.fn.execute"highlight","\n")local aD={}for _,s in ipairs(az)do if s~=""then if s:sub(1,1)==" "then local aE=s:match"%s+(.*)"aD[#aD]=aD[#aD]..aE else table.insert(aD,s)end end end;self.tmpbuf=self:get_tmp_buffer()vim.api.nvim_buf_set_lines(self.tmpbuf,0,-1,false,aD)for r,s in ipairs(aD)do local aF=string.find(s,"xxx",1,true)-1;local aG=aF+3;local aH=string.match(s,"([^ ]*)%s+.*")pcall(vim.api.nvim_buf_add_highlight,self.tmpbuf,0,aH,r-1,aF,aG)end;self:set_preview_buf(self.tmpbuf)end;local aI="^"..c.strip_ansi_coloring(J).."\\>"pcall(vim.api.nvim_buf_clear_namespace,self.tmpbuf,self.ns_previewer,0,-1)pcall(e.nvim_win_call,self.win.preview_winid,function()e.nvim_win_set_cursor(0,{1,0})g.clearmatches()g.search(aI,"W")if self.win.winopts.__hl.search then g.matchadd(self.win.winopts.__hl.search,aI)end;self.orig_pos=e.nvim_win_get_cursor(0)c.zz()end)self.win:update_scrollbar()end;k.quickfix=k.base:extend()function k.quickfix:should_clear_preview(_)return true end;function k.quickfix:gen_winopts()local w={wrap=self.win.preview_wrap,cursorline=false,number=false}return vim.tbl_extend("keep",w,self.winopts)end;function k.quickfix:new(l,m,n)k.quickfix.super.new(self,l,m,n)return self end;function k.quickfix:close()k.highlights.super.close(self)end;function k.quickfix:populate_preview_buf(J)local aJ=J:match("[(%d+)]")if not aJ or tonumber(aJ)<=0 then return end;local aK=self.opts._is_loclist and vim.fn.getloclist(self.win.src_winid,{all="",nr=tonumber(aJ)})or vim.fn.getqflist({all="",nr=tonumber(aJ)})if vim.tbl_isempty(aK)or vim.tbl_isempty(aK.items)then return end;local Z={}for _,aL in ipairs(aK.items)do table.insert(Z,string.format("%s|%d col %d|%s",a.HOME_to_tilde(a.relative(vim.api.nvim_buf_get_name(aL.bufnr),vim.loop.cwd())),aL.lnum,aL.col,aL.text))end;self.tmpbuf=self:get_tmp_buffer()vim.api.nvim_buf_set_lines(self.tmpbuf,0,-1,false,Z)vim.api.nvim_buf_set_option(self.tmpbuf,"filetype","qf")self:set_preview_buf(self.tmpbuf)self.win:update_title(string.format("%s: %s",aJ,aK.title))self.win:update_scrollbar()end;k.autocmds=k.buffer_or_file:extend()function k.autocmds:new(l,m,n)k.autocmds.super.new(self,l,m,n)return self end;function k.autocmds:gen_winopts()if not self._is_vimL_command then return self.winopts end;local w={wrap=true,cursorline=false,number=false}return vim.tbl_extend("keep",w,self.winopts)end;function k.autocmds:populate_preview_buf(J)if not self.win or not self.win:validate_preview()then return end;local U=self:parse_entry(J)if vim.tbl_isempty(U)then return end;self._is_vimL_command=false;if U.path=="<none>"then self._is_vimL_command=true;U.path=J:match("[^:]+│")local aM=J:match("[^│]+$")local Z=vim.split(aM,"\n")local a0=self:get_tmp_buffer()vim.api.nvim_buf_set_lines(a0,0,-1,false,Z)vim.api.nvim_buf_set_option(a0,"filetype","vim")self:set_preview_buf(a0)self:preview_buf_post(U)else self.super.populate_preview_buf(self,J)end end;return k
