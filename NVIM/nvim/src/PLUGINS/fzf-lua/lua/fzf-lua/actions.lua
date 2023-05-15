local a=require"fzf-lua.utils"local b=require"fzf-lua.path"local c={}local d="default"c.expect=function(e)if not e then return nil end;local f={}for g,h in pairs(e)do if g~=d and h~=false then table.insert(f,g)end end;if#f>0 then return string.format("--expect=%s",table.concat(f,","))end;return nil end;c.normalize_selected=function(e,i)if not e or not i then return end;local j=d;if a.tbl_length(e)>1 or not e[d]then if#i[1]>0 then j=i[1]end;local k={}for l=2,#i do table.insert(k,i[l])end;return j,k else return j,i end end;c.act=function(e,i,m)if not e or not i then return end;local n,k=c.normalize_selected(e,i)local j=e[n]if type(j)=="table"then for o,p in ipairs(j)do p(k,m)end elseif type(j)=="function"then j(k,m)elseif type(j)=="string"then vim.cmd(j)elseif n~=d then a.warn(("unsupported action: '%s', type:%s"):format(n,type(j)))end end;c.dummy_abort=function()end;c.resume=function(o,o)vim.cmd("lua require'fzf-lua'.resume()")end;c.vimcmd=function(q,i,r)for l=1,#i do vim.cmd(("%s %s"):format(q,r and i[l]or vim.fn.fnameescape(i[l])))end end;c.vimcmd_file=function(q,i,m)local s=vim.api.nvim_buf_get_name(0)local t=a.is_term_buffer(0)for l=1,#i do local u=b.entry_to_file(i[l],m,m.force_uri)if u.path=="<none>"then goto v end;u.ctag=m._ctag and b.entry_to_ctag(i[l])local w=u.path or u.uri and u.uri:match("^%a+://(.*)")if not b.starts_with_separator(w)then w=b.join({m.cwd or vim.loop.cwd(),w})end;if q=="e"and s~=w and not vim.o.hidden and a.buffer_is_dirty(nil,false,true)then if a.save_dialog(nil)then q=q.."!"else return end end;if not t then vim.cmd("normal! m`")end;if q~="e"or s~=w then if u.path then local x=b.relative(u.path,vim.loop.cwd())vim.cmd(q.." "..vim.fn.fnameescape(x))elseif q~="e"then vim.cmd(q)end end;if u.uri then vim.lsp.util.jump_to_location(u,"utf-16")elseif u.ctag then vim.api.nvim_win_set_cursor(0,{1,0})vim.fn.search(u.ctag,"W")elseif u.line>1 or u.col>1 then u.col=u.col and u.col>0 and u.col or 1;vim.api.nvim_win_set_cursor(0,{tonumber(u.line),tonumber(u.col)-1})end;if not t and not m.no_action_zz then vim.cmd("norm! zvzz")end::v::end end;c.file_edit=function(i,m)local q="e"c.vimcmd_file(q,i,m)end;c.file_split=function(i,m)local q="new"c.vimcmd_file(q,i,m)end;c.file_vsplit=function(i,m)local q="vnew"c.vimcmd_file(q,i,m)end;c.file_tabedit=function(i,m)local q="tabnew"c.vimcmd_file(q,i,m)end;c.file_open_in_background=function(i,m)local q="badd"c.vimcmd_file(q,i,m)end;local y=function(i,m,z)local A={}for l=1,#i do local B=b.entry_to_file(i[l],m)local C=i[l]:match(":%d+:%d?%d?%d?%d?:?(.*)$")table.insert(A,{filename=B.bufname or B.path,lnum=B.line,col=B.col,text=C})end;if z then vim.fn.setloclist(0,{}," ",{nr="$",items=A,title=m.__resume_data.last_query})vim.cmd(m.lopen or"lopen")else vim.fn.setqflist({}," ",{nr="$",items=A,title=m.__resume_data.last_query})vim.cmd(m.copen or"copen")end end;c.file_sel_to_qf=function(i,m)y(i,m)end;c.file_sel_to_ll=function(i,m)y(i,m,true)end;c.file_edit_or_qf=function(i,m)if#i>1 then return c.file_sel_to_qf(i,m)else return c.file_edit(i,m)end end;c.file_switch=function(i,m)local D=nil;local u=b.entry_to_file(i[1])local w=u.path;if not b.starts_with_separator(w)then w=b.join({m.cwd or vim.loop.cwd(),w})end;for o,E in ipairs(vim.api.nvim_list_bufs())do local F=vim.api.nvim_buf_get_name(E)if F and F==w then D=E;break end end;if not D then return false end;local t=a.is_term_buffer(0)if not t then vim.cmd("normal! m`")end;local G=a.winid_from_tabh(0,D)if G then vim.api.nvim_set_current_win(G)end;if u.line>1 or u.col>1 then vim.api.nvim_win_set_cursor(0,{tonumber(u.line),tonumber(u.col)-1})end;if not t and not m.no_action_zz then vim.cmd("norm! zvzz")end;return true end;c.file_switch_or_edit=function(...)c.file_switch(...)c.file_edit(...)end;c.vimcmd_buf=function(q,i,m)local s=vim.api.nvim_get_current_buf()local H=vim.api.nvim_win_get_cursor(0)[1]local t=a.is_term_buffer(0)for l=1,#i do local u=b.entry_to_file(i[l],m)if not u.bufnr then return end;assert(type(u.bufnr)=="number")if q=="b"and s~=u.bufnr and not vim.o.hidden and a.buffer_is_dirty(nil,false,true)then if a.save_dialog(nil)then q=q.."!"else return end end;if not t then vim.cmd("normal! m`")end;if q~="b"or s~=u.bufnr then local I=q.." "..u.bufnr;local J,K=pcall(vim.cmd,I)if not J then a.warn(("':%s' failed: %s"):format(I,K))end end;if q~="bd"and not m.no_action_set_cursor then if s~=u.bufnr or H~=u.line then u.col=u.col and u.col>0 and u.col or 1;vim.api.nvim_win_set_cursor(0,{tonumber(u.line),tonumber(u.col)-1})end;if not t and not m.no_action_zz then vim.cmd("norm! zvzz")end end end end;c.buf_edit=function(i,m)local q="b"c.vimcmd_buf(q,i,m)end;c.buf_split=function(i,m)local q="split | b"c.vimcmd_buf(q,i,m)end;c.buf_vsplit=function(i,m)local q="vertical split | b"c.vimcmd_buf(q,i,m)end;c.buf_tabedit=function(i,m)local q="tab split | b"c.vimcmd_buf(q,i,m)end;c.buf_del=function(i,m)local q="bd"local L=vim.tbl_filter(function(M)local E=tonumber(M:match("%[(%d+)"))return not a.buffer_is_dirty(E,true,false)end,i)c.vimcmd_buf(q,L,m)end;c.buf_switch=function(i,o)local N=tonumber(i[1]:match("(%d+)%)"))local O=N and vim.api.nvim_list_tabpages()[N]if O then vim.api.nvim_set_current_tabpage(O)else O=vim.api.nvim_win_get_tabpage(0)end;local D=tonumber(string.match(i[1],"%[(%d+)"))if D then local G=a.winid_from_tabh(O,D)if G then vim.api.nvim_set_current_win(G)end end end;c.buf_switch_or_edit=function(...)c.buf_switch(...)c.buf_edit(...)end;c.buf_sel_to_qf=function(i,m)return y(i,m)end;c.buf_sel_to_ll=function(i,m)return y(i,m,true)end;c.buf_edit_or_qf=function(i,m)if#i>1 then return c.buf_sel_to_qf(i,m)else return c.buf_edit(i,m)end end;c.colorscheme=function(i)local P=i[1]vim.cmd("colorscheme "..P)end;c.ensure_insert_mode=function()a.warn("calling 'ensure_insert_mode' is no longer required and can be safely omitted.")end;c.run_builtin=function(i)local Q=i[1]vim.cmd(string.format("lua require'fzf-lua'.%s()",Q))end;c.ex_run=function(i)local I=i[1]vim.cmd("stopinsert")vim.fn.feedkeys(string.format(":%s",I),"n")return I end;c.ex_run_cr=function(i)local I=c.ex_run(i)a.feed_keys_termcodes("<CR>")vim.fn.histadd("cmd",I)end;c.exec_menu=function(i)local I=i[1]vim.cmd("emenu "..I)end;c.search=function(i)local R=i[1]vim.cmd("stopinsert")vim.fn.feedkeys(string.format("/%s",R),"n")return R end;c.search_cr=function(i)local R=c.search(i)a.feed_keys_termcodes("<CR>")vim.fn.histadd("search",R)end;c.goto_mark=function(i)local S=i[1]S=S:match("[^ ]+")vim.cmd("stopinsert")vim.cmd("normal! '"..S)end;c.goto_jump=function(i,m)if m.jump_using_norm then local T,o,o,o=i[1]:match("(%d+)%s+(%d+)%s+(%d+)%s+(.*)")if tonumber(T)then vim.cmd(("normal! %d"):format(T))end else local o,H,U,V=i[1]:match("(%d+)%s+(%d+)%s+(%d+)%s+(.*)")local J,K=pcall(vim.fn.expand,V)if not J then V=""else V=K end;if not V or not vim.loop.fs_stat(V)then V=vim.api.nvim_buf_get_name(0)end;local u=("%s:%d:%d:"):format(V,tonumber(H),tonumber(U)+1)c.file_edit({u},m)end end;c.keymap_apply=function(i)local W=i[1]:match("[│]%s+(.*)%s+[│]")vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(W,true,false,true),"t",true)end;c.spell_apply=function(i)local X=i[1]vim.cmd("normal! ciw"..X)vim.cmd("stopinsert")end;c.set_filetype=function(i)vim.api.nvim_buf_set_option(0,"filetype",i[1])end;c.packadd=function(i)for l=1,#i do vim.cmd("packadd "..i[l])end end;local function Y(Z)return vim.tbl_map(function(_)return _:match("[^%s]+")end,Z)end;c.help=function(i)local q="help"c.vimcmd(q,Y(i),true)end;c.help_vert=function(i)local q="vert help"c.vimcmd(q,Y(i),true)end;c.help_tab=function(i)local q="tab help"c.vimcmd(q,Y(i),true)end;local function a0(Z)return vim.tbl_map(function(_)return _:match("[^[,( ]+")end,Z)end;c.man=function(i)local q="Man"c.vimcmd(q,a0(i))end;c.man_vert=function(i)local q="vert Man"c.vimcmd(q,a0(i))end;c.man_tab=function(i)local q="tab Man"c.vimcmd(q,a0(i))end;c.git_switch=function(i,m)local I=b.git_cwd({"git","checkout"},m)local a1=a.git_version()if a1 and a1>=2.23 then I=b.git_cwd({"git","switch"},m)end;local a2=i[1]:match("[^ ]+")if a2:find("%*")~=nil then return end;if a2:find("^remotes/")then table.insert(I,"--detach")end;table.insert(I,a2)local a3=a.io_systemlist(I)if a.shell_error()then a.err(unpack(a3))else a.info(unpack(a3))vim.cmd("edit!")end end;c.git_checkout=function(i,m)local a4=b.git_cwd({"git","checkout"},m)local a5=b.git_cwd({"git","rev-parse","--short HEAD"},m)local a6=i[1]:match("[^ ]+")if a.input("Checkout commit "..a6 .."? [y/n] ")=="y"then local a7=a.io_systemlist(a5)if a6==a7 then return end;table.insert(a4,a6)local a3=a.io_systemlist(a4)if a.shell_error()then a.err(unpack(a3))else a.info(unpack(a3))vim.cmd("edit!")end end end;local a8=function(i,m,I)for o,a9 in ipairs(i)do local B=b.relative(b.entry_to_file(a9,m).path,m.cwd)local aa=vim.deepcopy(I)table.insert(aa,B)local a3=a.io_systemlist(aa)if a.shell_error()then a.err(unpack(a3))end end end;c.git_stage=function(i,m)local I=b.git_cwd({"git","add","--"},m)a8(i,m,I)end;c.git_unstage=function(i,m)local I=b.git_cwd({"git","reset","--"},m)a8(i,m,I)end;c.git_reset=function(i,m)local I=b.git_cwd({"git","checkout","HEAD","--"},m)a8(i,m,I)end;c.git_stash_drop=function(i,m)local I=b.git_cwd({"git","stash","drop"},m)a8(i,m,I)end;c.git_stash_pop=function(i,m)if a.input("Pop "..#i.." stash(es)? [y/n] ")=="y"then local I=b.git_cwd({"git","stash","pop"},m)a8(i,m,I)vim.cmd("e!")end end;c.git_stash_apply=function(i,m)if a.input("Apply "..#i.." stash(es)? [y/n] ")=="y"then local I=b.git_cwd({"git","stash","apply"},m)a8(i,m,I)vim.cmd("e!")end end;c.git_buf_edit=function(i,m)local I=b.git_cwd({"git","show"},m)local ab=b.git_root(m,true)local ac=vim.api.nvim_get_current_win()local ad=vim.bo.filetype;local B=b.relative(vim.fn.expand("%:p"),ab)local a6=i[1]:match("[^ ]+")table.insert(I,a6 ..":"..B)local ae=a.io_systemlist(I)local af=vim.api.nvim_create_buf(true,true)local ag=string.gsub(B,"$","["..a6 .."]")vim.api.nvim_buf_set_lines(af,0,0,true,ae)vim.api.nvim_buf_set_name(af,ag)vim.api.nvim_buf_set_option(af,"buftype","nofile")vim.api.nvim_buf_set_option(af,"bufhidden","wipe")vim.api.nvim_buf_set_option(af,"filetype",ad)vim.api.nvim_buf_set_option(af,"modifiable",false)vim.api.nvim_win_set_buf(ac,af)end;c.git_buf_tabedit=function(i,m)vim.cmd("tab split")c.git_buf_edit(i,m)end;c.git_buf_split=function(i,m)vim.cmd("split")c.git_buf_edit(i,m)end;c.git_buf_vsplit=function(i,m)vim.cmd("vsplit")c.git_buf_edit(i,m)end;c.arg_add=function(i,m)local q="argadd"c.vimcmd_file(q,i,m)end;c.arg_del=function(i,m)local q="argdel"c.vimcmd_file(q,i,m)end;c.grep_lgrep=function(o,m)assert(m.__MODULE__ and type(m.__MODULE__.grep)=="function"or type(m.__MODULE__.live_grep)=="function")local ah=vim.tbl_extend("keep",{search=false,resume=true,resume_search_default="",rg_glob=m.rg_glob or m.__call_opts.rg_glob,requires_processing=m.rg_glob or m.__call_opts.rg_glob,__prev_query=not m.fn_reload and m.__resume_data.last_query,query=m.fn_reload and m.__call_opts.__prev_query,ctags_file=m.ctags_file},m.__call_opts or{})if m.fn_reload then m.__MODULE__.grep(ah)else m.__MODULE__.live_grep(ah)end end;c.sym_lsym=function(o,m)assert(m.__MODULE__ and type(m.__MODULE__.workspace_symbols)=="function"or type(m.__MODULE__.live_workspace_symbols)=="function")local ah=vim.tbl_extend("keep",{resume=true,lsp_query=false,__prev_query=not m.fn_reload and m.__resume_data.last_query,query=m.fn_reload and m.__call_opts.__prev_query},m.__call_opts or{})if m.fn_reload then m.__MODULE__.workspace_symbols(ah)else m.__MODULE__.live_workspace_symbols(ah)end end;c.tmux_buf_set_reg=function(i,m)local af=i[1]:match("^%[(.-)%]")local ai=vim.fn.system({"tmux","show-buffer","-b",af})if not a.shell_error()and ai and#ai>0 then m.register=m.register or[["]]local J,aj=pcall(vim.fn.setreg,m.register,ai)if J then a.info(string.format("%d characters copied into register %s",#ai,m.register))else a.err(string.format("setreg(%s) failed: %s",m.register,aj))end end end;c.paste_register=function(i)local ak=i[1]:match("%[(.-)%]")local J,ai=pcall(vim.fn.getreg,ak)if J and#ai>0 then vim.api.nvim_paste(ai,false,-1)end end;c.set_qflist=function(i,m)local al=i[1]:match("[(%d+)]")vim.cmd(string.format("%d%s",tonumber(al),m._is_loclist and"lhistory"or"chistory"))vim.cmd(m._is_loclist and"lopen"or"copen")end;c.apply_profile=function(i,m)local am=i[1]:match("[^:]+")local an=i[1]:match(":([^%s]+)")local J=a.load_profile(am,an,m.silent)if J then vim.cmd(string.format([[lua require("fzf-lua").setup({"%s"})]],an))end end;c.complete_insert=function(i,m)local M=vim.api.nvim_get_current_line()local ao=m.cmp_string_col>1 and M:sub(1,m.cmp_string_col-1)or""local ap=M:sub(m.cmp_string_col+(m.cmp_string and#m.cmp_string or 0))local u=i[1]if m.cmp_is_file then u=b.relative(b.entry_to_file(i[1],m).path,m.cwd)elseif m.cmp_is_line then u=i[1]:match("^.*:%d+:%s(.*)")end;local aq=(m.cmp_prefix or"")..u;vim.api.nvim_set_current_line(ao..aq..ap)vim.api.nvim_win_set_cursor(0,{m.cmp_string_row,m.cmp_string_col+#aq-2})if m.cmp_mode=="i"then vim.cmd[[noautocmd lua vim.api.nvim_feedkeys('a', 'n', true)]]end end;return c
