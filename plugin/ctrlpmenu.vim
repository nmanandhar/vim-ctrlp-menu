if !exists('g:loaded_ctrlp') || !g:loaded_ctrlp
  finish
endif

function! s:ctrpMenu(menuid)
    call ctrlp#init(ctrlp#menu#id(a:menuid))
endfunction

function! s:menu_completion(argLead,cmdLine,cursorPos)
    return insert(ctrlp#menu#names(),"ALL")
endfunction

command! -nargs=? -complete=customlist,s:menu_completion CtrlpMenu call s:ctrpMenu(<q-args>)
