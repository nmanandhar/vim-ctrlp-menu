" ========j==============l======================================================
" File:          autoload/ctrlp/menu.vim
" Description:   Create Your Own CtrlP Menu of Commands
" Author:        Nirmal Manandhar (github.com/nmanandhar)
" =============================================================================
let g:loaded_ctrlp_menu=1
let s:menu_ids={}
let s:current_menu={} "Dictionary whose keys are currently displayed in the menu
let s:default_menu={}

let g:ctrlp_use_default_menu = get(g:,'ctrlp_use_default_menu',1)

function! s:getMenus()
    let menus= get(g:,'ctrlp_menus',{})
    if type(menus) != v:t_dict
        call s:log("Invalid setting. g:ctrlp_menus must be a map")
    endif

    if(g:ctrlp_use_default_menu)
        let menus.default_menu = {
                    \   "copy current directory to clipboard" : 'let @+=getcwd()',
                    \   "copy file path to clipboard"      : "let @+=expand('%:p')",
                    \   "yank entire file to clipboard"      : "%y+",
                    \   }
    endif
    return menus
endfunction

function! ctrlp#menu#init(menuId)
    let s:current_menu = s:getMenu(a:menuId)
    return keys(s:current_menu)
endfunction

"Given a menuId returns a dictionary of menu labels
"and commands. If the menuId is not recognized, a dictionary
"containing all the menus is returned
function! s:getMenu(menuId)
    let s:menus = s:getMenus()
    if(has_key(s:menus,a:menuId))
        return s:menus[a:menuId]
    else
        "Combine all options
        let allMenuItems={}
        for key in keys(s:menus)
            call extend(allMenuItems, s:menus[key])
        endfor
        return allMenuItems
    endif
endfunction

function! ctrlp#menu#names()
    return keys(s:getMenus())
endfunction

"Callback when a menu item is selcted
"Simply executes the command associated with the selectedValue
function! ctrlp#menu#callback(mode, selectedValue)
    call ctrlp#exit()
    redraw
    if(has_key(s:current_menu,a:selectedValue))
        execute s:current_menu[a:selectedValue]
    endif
endfunction

function! ctrlp#menu#id(menu)
    if(!has_key(s:menu_ids,a:menu))
        call add( g:ctrlp_ext_vars, {
                    \ 'init': 'ctrlp#menu#init("' . a:menu . '")',
                    \ 'accept': 'ctrlp#menu#callback',
                    \ 'lname': 'menu ' . a:menu,
                    \ 'sname': a:menu,
                    \ 'type': 'line', 
                    \ 'sort': 0,
                    \ })
        let s:menu_ids[a:menu] = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
    endif
    return s:menu_ids[a:menu]
endfunction

function! s:log(str)
    echom a:str
endfunction
