" Title:        lf.vim
" Description:  Stupid Lf wrapper for Vim
" Last Change:  22 August 2022
" Mainteiner:   Gabriel G. de Brito https://github.com/gboncoffee
" Location:     plugin/lf.vim
" License:      MIT

if exists('g:autoloaded_lf')
    finish
endif

let g:autoloaded_lf = 1

" Section:       config

if !exists('g:lf_change_cwd')
    let g:lf_change_cwd=0
endif

if !exists('g:lf_hijack_netrw')
    let g:lf_hijack_netrw = 1
endif

if !exists('g:lf_change_cwd_cmd')
    let g:lf_change_cwd_cmd = 'cd'
endif

" Section:      commands

command! -complete=file -nargs=* Lf call lf#Lf(g:lf_change_cwd, <q-args>)
command! -complete=file -nargs=* LfNoChangeCwd call lf#Lf(0, <q-args>)
command! -complete=file -nargs=* LfChangeCwd call lf#Lf(1, <q-args>)

" Section:      netrw hijack

if g:lf_hijack_netrw == 1

    " this is basically a copy of the netrw hijack from nerdtree
    " https://github.com/preservim/nerdtree
    augroup LfHijackNetrw
        autocmd VimEnter * silent! autocmd! FileExplorer
        autocmd BufEnter,VimEnter * call lf#CheckDir(expand('<amatch>'))
    augroup END

endif
