if !exists("g:agprg")
  let g:agprg="ag --nogroup --column --literal"
endif

function! s:Ag(cmd, args, ...)
  redraw
  if exists("g:agpre")
    silent execute g:agpre
  endif
  echo "Searching ..."

  if empty(a:args)
    let l:grepargs = expand("<cword>")
  else
    let l:grepargs = a:args
  end

  if a:cmd =~# '-g$'
      let g:agformat="%f"
  else
      let g:agformat="%f:%l:%c:%m"
  end

  let grepprg_bak=&grepprg
  let grepformat_bak=&grepformat
  try
    let &grepprg=g:agprg
    let &grepformat=g:agformat
    let l:grepargs = substitute(l:grepargs, '"', '\\\"', "g")
    if a:0 > 0
      silent execute a:cmd . ' "' . l:grepargs . '" ' . a:1
    else
      silent execute a:cmd . ' "' . l:grepargs . '"'
    endif
  finally
    let &grepprg=grepprg_bak
    let &grepformat=grepformat_bak
  endtry

  if a:cmd =~# '^l'
    botright lopen
  else
    botright copen
  endif

  if exists("g:aghighlight")
    let @/=a:args
    set hlsearch
  end

  redraw!
endfunction

function! s:AgFromSearch(cmd, args)
  let search =  getreg('/')
  let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
  call s:Ag(a:cmd, '"' .  search .'" '. a:args)
endfunction

command! -bang -nargs=* -complete=file Ag call s:Ag('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgAdd call s:Ag('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFromSearch call s:AgFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAg call s:Ag('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LAgAdd call s:Ag('lgrepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file AgFile call s:Ag('grep<bang> -g', <q-args>)
command! -bang -nargs=* -complete=file AgNotes call s:Ag('grep<bang>', <q-args>, '~/.vim/notes')
