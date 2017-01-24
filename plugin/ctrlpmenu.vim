" ==============================================================================
" File:          plugin/ctrlpmenu.vim
" Description:   Mappings and abbreviations for ctrlp menu
" Author:        Nirmal Manandhar (github.com/nmanandhar)
" =============================================================================
if !exists('g:loaded_ctrlp') || !g:loaded_ctrlp
    finish
endif

if(exists("g:loaded_ctrpmenu") && ! exists("g:mode_plugin_development"))
        finish
endif
let g:loaded_ctrpmenu = 1

command! -nargs=? -complete=customlist,s:menu_completion CtrlpMenu call s:openMenu(<q-args>)
command! -nargs=0 CtrlpMenuMenus call s:openMenuOfMenus()

if ! exists("g:ctrlpmenu_skip_maps")
    try
        nnoremap <unique> <leader>m :CtrlpMenuMenus<cr>
    catch /mapping already exists.*/
    endtry
endif

if !exists("g:ctrlpmenu_skip_abbrev")
    cabbrev menu CtrlpMenu
    cabbrev menus CtrlpMenuMenus
endif

function! s:openMenu(menuid)
    call ctrlp#menu#setFiletype(&filetype)
    call ctrlp#init(ctrlp#menu#id(a:menuid))
endfunction

function! s:openMenuOfMenus()
    call ctrlp#menu#setFiletype(&filetype)
    call ctrlp#init(ctrlp#menu#idMenuOfMenu())
endfunction

function! s:menu_completion(argLead,cmdLine,cursorPos)
    if( a:argLead=="" )
        return ctrlp#menu#names()
    else
        let completionResults=[]
        let userInput = tolower(a:argLead)

        for menu in ctrlp#menu#names()
            if(stridx(menu,userInput) == 0)
                call add(completionResults,menu)
            endif
        endfor
        return completionResults
    endif
endfunction
