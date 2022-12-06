" Vim config file
"let g:ycm_server_keep_logfiles = 1
"let g:ycm_server_log_level = 'debug'

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'


Plugin 'Valloric/YouCompleteMe'
"The youcompleteme package plugin

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'

" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'

" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'

" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


"default settings
colo default " Default color scheme setting
syntax on
set number
set tabstop=8
set expandtab
set hlsearch
set laststatus=2
set statusline+=%2*%F%*
" note: using '^' symbol for linespaces cuz i can
set statusline+=%1*^^^^%*
set statusline+=%3*%{fugitive#statusline()}%2*

" hlsearch colors (white on blue)
hi Search cterm=NONE ctermfg=white ctermbg=blue

" Default color group
hi User2 ctermfg=black
hi User2 ctermbg=white

" Color group for git bar
hi User3 ctermfg=010
hi User3 ctermbg=black

" Define a group for line spaces
hi User1 ctermfg=white
hi User1 ctermbg=white
" set user using '%#*' then define user color with 'hi User# ctermbg=xxx'

"Highlighting extra whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

"let &colorcolumn=join(range(101,999),",") "block highlight after line 100
let &colorcolumn="101,".join(range(151,999),",") "highlight column 100 and the range after 150
highlight ColorColumn ctermbg=235 guibg=#2c2d27

"YCM config settings
"let g:ycm_global_ycm_extra_conf = '~/work/purity/.ycm_extra_conf.py'
" Blacklist everything but our ycm conf
"let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
"let g:ycm_extra_conf_globlist = ['!~/*']
let g:ycm_confirm_extra_conf = 0
let g:ycm_always_populate_location_list = 1
 highlight YcmErrorSign ctermbg=160
 highlight YcmErrorSection ctermbg=160
 let g:ycm_allow_changing_updatetime = 0
 let g:ycm_error_symbol = '>>'
 "let g:max_diagnostics_to_display = 0
"let max_diagnostics_to_display = 0
"Function decls
func! CmdCallback(cmd, timer)
        execute a:cmd
endfunc


" Code navigation with Ctrl-] , use Ctrl-O to get back to previous location
 nnoremap <silent> <C-]> :YcmCompleter GoTo<CR>
" nnoremap <silent> <C-[> :YcmCompleter GoToInclude<CR>
 nnoremap <silent> <C-\> :YcmCompleter GoToDeclaration<CR>
 nnoremap <silent> <C-,> :YcmCompleter GoToDefinition<CR>

" Keymaps
inoremap <C-Right> <End>
inoremap <C-Left> <Home>

nnoremap <C-Right> <End>
nnoremap <C-Left> <Home>
"      The following command will remove all trailing whitespaces
nnoremap <f5> :%s/\s\+$//e<return>
"      The following command will set vim to paste mode (no auto-indent)
set pastetoggle=<f6>

nnoremap <C-h> :set colorcolumn=<return>

" Command Aliases
" Fugitive 'Git blame' alias
command Gblame Git<space>blame


