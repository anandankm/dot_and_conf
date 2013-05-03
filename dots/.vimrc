syntax on
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
set textwidth=80
set makeprg=ant
set efm=\ %#[javac]\ %#%f:%l:%c:%*\\d:%*\\d:\ %t%[%^:]%#:%m,\%A\ %#[javac]\ %f:%l:\ %m,%-Z\ %#[javac]\ %p^,%-C%.%#
set background=dark

"map <C-left> <C-left> ==> to accomplish in screen mode
"map [1;5D <C-left>
"imap [1;5D <C-left>
"map <C-right> <C-right> ==> to accomplish in screen mode
"map [1;5C <C-right>
"imap [1;5C <C-right>
"map <C-s-left> <C-W><
map [1;6D <
"map <C-s-right> <C-W>>
map [1;6C >
"map <s-left> <C-W>h
map [1;2D h
"map <s-right> <C-W>l
map [1;2C l
"map <s-up> <C-W><up>
map [1;2A OA
"map <s-down> <C-W><down>
map [1;2B OB
map <F2> :NERDTreeToggle<CR>
map <F4> :s/\(    private \(\S*\) \(\S\)\(\w*\).*;\n\)/\1    public void set\U\3\E\4(\2 \3\4) { this.\3\4 = \3\4; }\r    public \2 get\U\3\E\4() { return this.\3\4; }\r/<CR>
map <F3> vwODOD"+y :vimgrep "public class +" ./**/*.java ~/Downloads/ingestion/framework/src/java/**/*.java<CR>
filetype plugin indent on
let NERDTreeShowHidden=1
map <s-tab> :s/\(\s\\|\S\)/    \1/<CR>
