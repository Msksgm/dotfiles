" "dein Scripts-----------------------------
" if &compatible
"   set nocompatible               " Be iMproved
" endif
" 
" " reset augroup
" augroup MyAutoCmd
"   autocmd!
" augroup END
" 
" " dein settings {{{
" " dein自体の自動インストール
" let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.vim') : $XDG_CACHE_HOME
" let s:dein_dir = s:cache_home . '/dein'
" let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
" if !isdirectory(s:dein_repo_dir)
"   call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
" endif
" let &runtimepath = s:dein_repo_dir .",". &runtimepath
" " プラグイン読み込み＆キャッシュ作成
" let s:toml_file = fnamemodify(expand('<sfile>'), ':h').'/dein.toml'
" if dein#load_state(s:dein_dir)
"   call dein#begin(s:dein_dir)
"   call dein#load_toml(s:toml_file)
"   call dein#end()
"   call dein#save_state()
" endif
" " 不足プラグインの自動インストール
" if has('vim_starting') && dein#check_install()
"   call dein#install()
" endif
" " }}}/
" 
" " Required:
" filetype plugin indent on
" syntax enable
" 
" call dein#add('itchyny/lightline.vim')
" "End dein Scripts-------------------------
" 
" let g:previm_open_cmd = 'open -a Google\ Chrome'
" 
" 
" "Setting---------------------------------
" set wildmenu
" 
" set scrolloff=999
" 
" "set relativenumber
" " set all で全てのオプションを表示できる
" set number
" 
" set clipboard+=unnamed
" 
" set backspace=indent,eol,start
" 
" set incsearch
" 
" 
" " netrw---------------
" filetype plugin on
" " ファイルツリーの表示形式、1にするとls -laのような表示になります
" let g:netrw_liststyle=1
" " ヘッダを非表示にする
" let g:netrw_banner=0
" " サイズを(K,M,G)で表示する
" let g:netrw_sizestyle="H"
" " 日付フォーマットを yyyy/mm/dd(曜日) hh:mm:ss で表示する
" let g:netrw_timefmt="%Y/%m/%d(%a) %H:%M:%S"
" " プレビューウィンドウを垂直分割で表示する
" let g:netrw_preview=1
" 
" nnoremap <Space>f :Ex<CR>
" 
" " lightline.vimの設定
" set laststatus=2 
" let g:lightline = {
"         \ 'colorscheme': 'wombat',
"         \ 'mode_map': {'c': 'NORMAL'},
"         \ 'active': {
"         \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
"         \ },
"         \ 'component_function': {
"         \   'modified': 'LightlineModified',
"         \   'readonly': 'LightlineReadonly',
"         \   'fugitive': 'LightlineFugitive',
"         \   'filename': 'LightlineFilename',
"         \   'fileformat': 'LightlineFileformat',
"         \   'filetype': 'LightlineFiletype',
"         \   'fileencoding': 'LightlineFileencoding',
"         \   'mode': 'LightlineMode'
"         \ }
"         \ }
" 
" function! LightlineModified()
" 	  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
"   endfunction
" 
"   function! LightlineReadonly()
" 	    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
"     endfunction
" 
"     function! LightlineFilename()
" 	      return ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
" 	              \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
" 	              \  &ft == 'unite' ? unite#get_status_string() :
" 	              \  &ft == 'vimshell' ? vimshell#get_status_string() :
" 	              \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
" 	              \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
"       endfunction
" 
"       function! LightlineFugitive()
" 	        if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
" 			    return fugitive#head()
" 			      else
" 				          return ''
" 					    endif
" 				    endfunction
" 
" 				    function! LightlineFileformat()
" 					      return winwidth(0) > 70 ? &fileformat : ''
" 				      endfunction
" 
" 				      function! LightlineFiletype()
" 					        return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
" 					endfunction
" 
" 					function! LightlineFileencoding()
" 						  return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
" 					  endfunction
" 
" 					  function! LightlineMode()
" 						    return winwidth(0) > 60 ? lightline#mode() : ''
" 					    endfunctio
" 
" " "mapping------------------------------
" " let mapleader = "\<Space>"
" " 
" " inoremap <silent>jj <ESC>
" " 
" " nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
" " 
" " " xやsでヤンクしないようにする
" "
" noremap x "_x
" nnoremap s "_s
" " 
" " noremap j gj
" " noremap k gk
" " noremap <Leader>h ^
" " noremap <Leader>l $
" " noremap ; :
" " let g:EasyMotion_do_mapping = 0 "Disable default mappings
" " " Jump to first match whith enter & space
" " let g:EasyMotion_enter_jump_first = 1
" " let g:EasyMotion_space_jump_first = 1
" " let g:EasyMotion_smartcase = 1
" " "let g:EasyMotion_use_migemo = 1
" " " nmap S <Plug>(easymotion-s)
" " " nmap s <Plug>(easymotion-s2)
" " nmap s <Plug>(easymotion-overwin-f2)
" " vmap s <Plug>(easymotion-s)
" " map <Leader>j <Plug>(easymotion-j)
" " map <Leader>k <Plug>(easymotion-k)
" " map / <Plug>(easymotion-sn)
" " omap / <Plug>(easymotion-tn)
" " map n <Plug>(easymotion-next)
" " map N <Plug>(easymotion-prev)
" " " s<CR>で前回のs{char}{char}をリピートできる
" " 
" " " nmap g/ <Plug>(easymotion-sn)
" " map f <Plug>(easymotion-fl)
" " map t <Plug>(easymotion-tl)
" " map F <Plug>(easymotion-Fl)
" " map T <Plug>(easymotion-Tl)
" " "map f <Plug>(easymotion-bd-fl)
" " "map t <Plug>(easymotion-bd-tl)
