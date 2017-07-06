call plug#begin('~/.vim/plugged')
Plug 'https://github.com/jalvesaq/Nvim-R'
Plug 'blueshirts/darcula'
Plug 'bling/vim-airline'
Plug 'valloric/youcompleteme'
Plug 'scrooloose/nerdtree'
Plug 'keith/sourcekittendaemon.vim'
call plug#end()
set nu
set clipboard=unnamed
syntax on
color darcula

set tabstop=4
set shiftwidth=4
set smarttab

set wrap

set ai 
set cin

set listchars=tab:··,space:·
set list

:setlocal spell spelllang=ru,en

let fortran_free_source=1
let fortran_have_tabs=1
let fortran_more_precise=1
let fortran_do_enddo=1

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

au BufNewFile,BufRead *.inc setlocal ft=fortran
