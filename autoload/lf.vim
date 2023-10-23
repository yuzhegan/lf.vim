" Location:     autoload/lf.vim

function! lf#AfterCloseLf(change)

    let l:buf_to_close=bufnr('%')
    let l:dir=system('cat /tmp/lfvim-lastdir 2> /dev/null')
    let l:file=system('cat /tmp/lfvim-selection 2> /dev/null')
    
    if a:change == 1 && !empty(l:dir)
        execute g:lf_change_cwd_cmd l:dir
    endif
    if !empty(l:file)
        execute 'edit' l:file
        " for some reason it didn't run filetype nor autocmd normally
        "
        " I really pray for these being the only needed autocmd
        filetype detect
        do BufAdd,BufEnter
    endif

    " make sure to close lf buffer
    if bufexists(l:buf_to_close)
        execute 'bd!' l:buf_to_close
    endif

endfunction

" this looks extremely ugly but it is what it is
if !has('nvim')
    function! lf#ExitJobHandlerChanging(job = 0, status = 0)
        call lf#AfterCloseLf(1)
    endfunction
    function! lf#ExitJobHandlerNotChanging(job = 0, status = 0)
        call lf#AfterCloseLf(0)
    endfunction
endif

function! lf#Lf(change=0, path='')

    let l:lf_cmd = 'lf -last-dir-path /tmp/lfvim-lastdir -selection-path /tmp/lfvim-selection'

    " we need to be sure that theese files aren't there
    call system('rm /tmp/lfvim-lastdir /tmp/lfvim-selection')

    " we need to make this because a:change get out of scope inside the autocmd
    if has('nvim')
        execute 'term' l:lf_cmd a:path
        " make sure lf buffer will be deleted on close
        setlocal bufhidden=wipe
        execute 'autocmd TermClose <buffer> call lf#AfterCloseLf('a:change ')'
        normal a
    else
        " this is 'gambiarra pura'
        if a:change
            call term_start(l:lf_cmd, {'exit_cb': function('lf#ExitJobHandlerChanging'), 'term_finish': 'open', 'curwin': 1})
        else
            call term_start(l:lf_cmd, {'exit_cb': function('lf#ExitJobHandlerNotChanging'), 'term_finish': 'open', 'curwin': 1})
        endif
    endif
    set filetype=lf

    " deletes that buffer that gets created when trying to edit a directory
    if bufexists(a:path)
        execute 'bd!' bufnr(a:path)
    endif

endfunction

function! lf#CheckDir(dir)

    if !isdirectory(a:dir)
        return
    endif
    
    call lf#Lf(g:lf_change_cwd, a:dir)

endfunction
