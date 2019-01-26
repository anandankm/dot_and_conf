execute pathogen#infect()
syntax on
source $VIMRUNTIME/macros/matchit.vim
set number
set hlsearch
set incsearch ignorecase
set autoindent
set smarttab
set expandtab
set smartindent
set ruler
set showcmd
set showmatch
set exrc
set term=xterm
set mouse=a
set tabstop=4
set shiftwidth=4
"set tw=76
set fo+=t
set makeprg=ant
set efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
set background=dark
" let g:NERDTreeDirArrows=0
" %F - Add full filepath to the statusline
" %l %c - Add line number and column number
set statusline+=%F\ %l:%c
" Always make statusline available
set laststatus=2
" Custom highlight colors for menu and selection
highlight Pmenu ctermfg=blue ctermbg=grey
highlight PmenuSel ctermfg=white ctermbg=grey

"map <C-left> <C-left> ==> to accomplish in screen mode
"map [1;5D <C-left>
"imap [1;5D <C-left>
"map <C-right> <C-right> ==> to accomplish in screen mode
"map [1;5C <C-right>
"imap [1;5C <C-right>
"map <C-s-left> <C-W><

map <C-K> :pyf /mathworks/hub/share/sbtools/release/R2018a.sbv1/external-apps/llvm/llvm-5.0.0/install/maci10p12-64/share/clang/clang-format.py<cr>
imap <C-K> <c-o>:pyf /mathworks/hub/share/sbtools/release/R2018a.sbv1/external-apps/llvm/llvm-5.0.0/install/maci10p12-64/share/clang/clang-format.py<cr>

map [1;6D <
"map <C-s-right> <C-W>>
map [1;6C >

"map <S-Left> h
"move to left window alt-left
"move to left window shift-left
map [1;3D h
map [1;2D h
"map <s-left> <C-W>h
"map <s-right> <C-W>l
"move to right window alt-right
"move to right window shift-right
map [1;3C l
map [1;2C l

"map <s-up> <C-W><up>
map [1;2A OA
"map <s-down> <C-W><down>
map [1;2B OB

map <F2> :NERDTreeToggle<CR>
map <F4> :s/\(    \(protected\\|private\) \(\S*\) \(\S\)\(\w*\).*;\n\)/\1    \/\*\*\r     * Setter method for \4\5\r     \*\/\r    public void set\U\4\E\5(\3 \4\5) {\r        this.\4\5 = \4\5;\r    }\r    \/\*\*\r     * Getter method for \4\5\r     \*\/\r    public \3 get\U\4\E\5() {\r        return this.\4\5;\r    }\r/<CR>
map <F3> vwODOD"+y :vimgrep "public class +" ./**/*.java ~/Downloads/ingestion/framework/src/java/**/*.java<CR>
filetype plugin indent on
let NERDTreeShowHidden=1
map <tab> :s/\(\s\\|\S\)/    \1/<CR>
map <s-tab> :s/^    //<CR>

"if has("autocmd")
"    au InsertEnter * silent execute "!gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/cursor_shape ibeam"
"    au InsertLeave * silent execute "!gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/cursor_shape block"
"endif

if has("mac")
    " For MAC OSX, everything y, yy goes to clipboard
    "set clipboard=unnamed
endif

" --- Filter out .p files ---
" let NERDTreeIgnore = ['\.p$']
" 
"
" --- Sort files in the tree:  .p files ---
" let NERDTreeSortOrder = ['\.p$']
" 
