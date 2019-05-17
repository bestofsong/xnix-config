set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

let s:vim_conf_dir = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:base_rc = s:vim_conf_dir . '/.base-vimrc'
:execute 'source ' . s:base_rc

" vim-plug插件 {{{
call plug#begin('~/.local/share/nvim/plugged')
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'ludovicchabant/vim-gutentags'
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
Plug 'w0rp/ale'
Plug 'bestofsong/vimconfig'
Plug 'leafgarland/typescript-vim'
Plug 'kien/ctrlp.vim'
Plug 'Yggdroot/indentLine'
Plug 'gabrielelana/vim-markdown'
Plug 'godlygeek/tabular'
Plug 'wellle/targets.vim'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-fugitive'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'ervandew/supertab'
call plug#end()
" }}}

