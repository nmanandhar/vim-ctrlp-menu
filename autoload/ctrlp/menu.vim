" ========j==============l======================================================
" File:          autoload/ctrlp/menus.vim
" Description:   Create Your Own CtrlP Menu of Commands
" Author:        Nirmal Manandhar (github.com/nmanandhar)
" =============================================================================
let g:loaded_ctrlp_menu=1
let s:menu_ids={}
let s:current_menu={} "Dictionary whose keys are currently displayed in the menu
let s:default_menu={}

let g:ctrlp_use_default_menu = get(g:,'ctrlp_use_default_menu',1)
let g:ctrlp_menus_filetypes = get(g:,'ctrlp_menus_filetypes',{})
let s:bufferFiletype=""


function! s:getMenus()
    let menus= get(g:,'ctrlp_menus',{})
    if type(menus) != v:t_dict
        call s:log("Invalid setting. g:ctrlp_menus must be a map")
    endif

    if(g:ctrlp_use_default_menu)
        if ! has_key(menus,'files')
            let menus.files = {}
        endif
        if ! has_key(menus,'emmet')
            let menus.emmet={}
        endif
        call extend(menus.files,{
                    \   "copy current directory to clipboard" : 'let @+=getcwd()',
                    \   "copy file path to clipboard"      : "let @+=expand('%:p')",
                    \   "yank entire file to clipboard"      : "%y+",
                    \   } )
        call extend(menus.emmet,{
                    \ "update tag <C-y>u" : "call emmet#updateTag()",
                    \ "wrap with abbreviation VISUAL MODE<C-y>," : "echom 'only works in visual mode Use <C-y>, in visual mode'" ,
                    \ "balance tag inward <C-y>d ":"call emmet#balanceTag(1)",
                    \ "balance tag outward <C-y>D":"call emmet#balanceTag(-1)",
                    \ "goto next edit point":"call emmet#balanceTag(-1)",
                    \ "update image size" : "call emmet#imageSize()",
                    \ "remove tag  <C-y>k" :"call emmet#removeTag()",
                    \ "split/join tag  <C-y>j" :"call emmet#splitJoinTag()" ,
                    \ "toggle comment       <C-y>/" :"call emmet#toggleComment()" ,
                    \ "make anchor from URL" :"call emmet#anchorizeURL()" ,
                    \ "make quoted text from URL <C-y>A" :"call emmet#anchorizeURL(1)" ,
                    \ "lorem ipsum" :"echom 'Goto insert mode and type lorem. Duh'" ,
                    \ "code pretty VISUAL MODE<C-Y>c" : "echom 'only works in visual mode. Use <C-y>c in visual mode'"
                    \ })

        if ! has_key(g:ctrlp_menus_filetypes,'emmet')
            call extend( g:ctrlp_menus_filetypes,{'emmet':'\(html\|xml\)'},'keep')
        endif
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
        let filetype = &filetype
        for menuId in keys(s:menus)
            if ! has_key(g:ctrlp_menus_filetypes, menuId)
                "filetype *
                call extend(allMenuItems, s:menus[menuId])
            else
                if s:bufferFiletype =~ g:ctrlp_menus_filetypes[menuId]
                    call extend(allMenuItems,s:menus[menuId ])
                endif
            endif
        endfor
            return allMenuItems
        endif
    endfunction

function! ctrlp#menu#names()
    let menuNames=[]
    for menuId in keys(s:getMenus())
        if ! has_key(g:ctrlp_menus_filetypes, menuId)
            "filetype *
            call add(menuNames,tolower(menuId))
        elseif &filetype =~ g:ctrlp_menus_filetypes[menuId]
            call add(menuNames,tolower(menuId))
        endif
    endfor
    return menuNames
endfunction

"Callback when a menu item is selected
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

function! ctrlp#menu#setFiletype(type)
    let s:bufferFiletype = a:type
    echom "Filetype set to " . a:type
endfunction

function! s:log(str)
    echom a:str
endfunction
