if !exists('g:loaded_ctrlp') || !g:loaded_ctrlp
  finish
endif

function! s:ctrpMenu(menuid)
    call ctrlp#menu#setFiletype(&filetype)
    call ctrlp#init(ctrlp#menu#id(a:menuid))
endfunction


function! s:menu_completion(argLead,cmdLine,cursorPos)
    if( a:argLead=="" )
        return insert(ctrlp#menu#names(),"ALL")
    else
        let menus=[]
        let userInput = tolower(a:argLead)
        echom "userInput " . userInput

        for menu in ctrlp#menu#names()
            echom "menu " . menu
            if(stridx(menu,userInput) ==0)
                call add(menus,menu)
            endif
        endfor
        return menus
    endif
endfunction

command! -nargs=? -complete=customlist,s:menu_completion CtrlpMenu call s:ctrpMenu(<q-args>)
