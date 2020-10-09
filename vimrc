call plug#begin()
Plug 'chriskempson/base16-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'
Plug 'edkolev/promptline.vim'
call plug#end()

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace = 256
  source ~/.vimrc_background
endif
hi Normal ctermbg = NONE

set noshowmode
let g:airline_theme = 'base16'
let g:airline_symbols_ascii = 1

let g:tmuxline_powerline_separators = 0
let g:tmuxline_theme = 'airline'

let g:promptline_powerline_symbols = 0
let g:promptline_theme = 'airline'

set number
set cursorline
set incsearch
set hlsearch
set tabstop=4
set shiftwidth=4
set expandtab

