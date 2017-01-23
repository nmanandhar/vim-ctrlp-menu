" ==============================================================================
" File:          autoload/ctrlp/menu.vim
" Description:   Create Your Own CtrlP Menu of Commands
" Author:        Nirmal Manandhar (github.com/nmanandhar)
" =============================================================================
let s:ctrlp_menuid_map={}
let s:current_menu={} "Dictionary whose keys are currently displayed in the menu

let g:ctrlp_menus_filetypes = get(g:,'ctrlp_menus_filetypes',{})
let s:bufferFiletype="" "Filetype of the buffer for the current menu

let s:CTRLPMENU_SKIP_DEFAULTMENU= get(g:,'ctrlpmenu_skip_defaultmenu',0)
let s:MENU_OF_MENU_ID = 'CTRLP_MENUOFMENU'
let s:SHORTEND_LIST_MAX_LENGTH = 80
let s:TAB = "\t"
let s:DEFAULT_MENU_FILES={
            \   "copy current directory to clipboard" : 'let @+=getcwd()',
            \   "copy file path to clipboard"      : "let @+=expand('%:p')",
            \   "yank file to clipboard"      : "%y+",
            \   "format file" :[
            \                   'normal! mw' . 'gg=G' . '`w',
            \                   'delmarks w'
            \                  ],
            \   }
let s:DEFAULT_MENU_EMMET={
            \ "update tag <C-y>u" : "call emmet#updateTag()",
            \ "wrap with abbreviation VISUAL MODE<C-y>," : "echom 'only works in visual mode Use <C-y>, in visual mode to wrap with abbreviation'" ,
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
            \ "code pretty VISUAL MODE<C-Y>c" : "echom 'only works in visual mode. Use <C-y>c in visual mode to code pretty'"
            \ }

function! ctrlp#menu#id(menu)
    if(!has_key(s:ctrlp_menuid_map,a:menu))
        call add( g:ctrlp_ext_vars, {
                    \ 'init': 'ctrlp#menu#init("' . a:menu . '")',
                    \ 'accept': 'ctrlp#menu#callback',
                    \ 'lname': 'menu ' . a:menu,
                    \ 'sname': a:menu,
                    \ 'type': 'line', 
                    \ 'sort': 0,
                    \ })
        let s:ctrlp_menuid_map[a:menu] = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
    endif
    return s:ctrlp_menuid_map[a:menu]
endfunction


function! ctrlp#menu#init(menuId)
    let s:current_menu = s:getMenuFor(a:menuId)
    return keys(s:current_menu)
endfunction

"Given a menuId returns a dictionary of menu labels
"and commands. If the menuId is not recognized, a dictionary
"containing all the menus is returned
function! s:getMenuFor(menuId)
    let menues = s:getMenus()
    if(has_key(menues,a:menuId))
        return menues[a:menuId]
    else
        return s:combineAll(menues)
    endif
endfunction


function! s:getMenus()
    let menus= get(g:,'ctrlp_menus',{})
    if type(menus) != v:t_dict
        call s:log("Invalid setting. g:ctrlp_menus must be a map")
        return {}
    endif

    if(!s:CTRLPMENU_SKIP_DEFAULTMENU)
        if ! has_key(menus,'files')
            let menus.files = {}
        endif
        if ! has_key(menus,'emmet')
            let menus.emmet={}
        endif
        call extend(menus.files,s:DEFAULT_MENU_FILES )

        call extend(menus.emmet,s:DEFAULT_MENU_EMMET)

        "Associate emmet with html filetype
        if ! has_key(g:ctrlp_menus_filetypes,'emmet')
            call extend( g:ctrlp_menus_filetypes,{'emmet':'\(html\|xml\)'},'keep')
        endif
    endif
    return menus
endfunction

function! s:combineAll(menues)
    let combinedMenuOptions={}
    for menuId in keys(a:menues)
        if ! has_key(g:ctrlp_menus_filetypes, menuId)  " No filetype associated with this menu
            call extend(combinedMenuOptions, a:menues[menuId])
        elseif s:bufferFiletype =~ g:ctrlp_menus_filetypes[menuId] " Check filetype before adding this menu
            call extend(combinedMenuOptions,a:menues[menuId ])
        endif
    endfor
    return combinedMenuOptions
endfunction

function! ctrlp#menu#names()
    let menuNames=[]
    for menuId in keys(s:getMenus())
        if ! has_key(g:ctrlp_menus_filetypes, menuId)
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
        let menuAction = s:current_menu[a:selectedValue]
        let commandType = type(menuAction)

        if(commandType==v:t_string)
            execute menuAction
        elseif commandType == v:t_list
            for action in menuAction
                execute action
            endfor
        endif
    endif
endfunction

function! ctrlp#menu#setFiletype(type)
    let s:bufferFiletype = a:type
endfunction

function! s:log(str)
    echom a:str
endfunction



" ---------------------------------------------------------------
"  Menu of Menu
" ---------------------------------------------------------------
function! ctrlp#menu#idMenuOfMenu()
    if !has_key(s:ctrlp_menuid_map,s:MENU_OF_MENU_ID)
        call add( g:ctrlp_ext_vars, {
                    \ 'init': 'ctrlp#menu#init_menuOfMenu()',
                    \ 'accept': 'ctrlp#menu#callback_menuOfMenu',
                    \ 'lname': 'CtrlP Custom Menu',
                    \ 'sname': 'CtrlP Menu',
                    \ 'type': 'tabs',
                    \ 'sort': 0,
                    \ })
        let s:ctrlp_menuid_map[s:MENU_OF_MENU_ID] = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
    endif
    return s:ctrlp_menuid_map[s:MENU_OF_MENU_ID]
endfunction


function! ctrlp#menu#init_menuOfMenu()
    let temp=[]
    let menus = s:getMenus()
    let menuIds = keys(menus)
    for menuId in menuIds
        if ! has_key(g:ctrlp_menus_filetypes, menuId)  " No filetype associated with this menu
            call add(temp, s:pad(menuId,20) . s:TAB . s:listToShortedString(keys(menus[menuId])))
        elseif s:bufferFiletype =~ g:ctrlp_menus_filetypes[menuId] " Check filetype before adding this menu
            call add(temp, s:pad(menuId,20) . s:TAB . s:listToShortedString(keys(menus[menuId])))
        endif
    endfor
    return temp
endfunction


function! s:listToShortedString(list)
    let joinedString = join(a:list, " , ")
    if(len(joinedString)> s:SHORTEND_LIST_MAX_LENGTH)
        let joinedString = strpart(joinedString,0,s:SHORTEND_LIST_MAX_LENGTH - 1) . " ..."
    endif
    return "[ " . joinedString . " ]"
endfunction

function! ctrlp#menu#callback_menuOfMenu(mode, selectedValue)
    let menuId =  s:removePadding(split(a:selectedValue, s:TAB)[0])
    call ctrlp#exit()
    call ctrlp#init(ctrlp#menu#id(menuId))
endfunction

function! s:pad(s,amt)
    return a:s . repeat(' ',a:amt - len(a:s))
endfunction

function! s:removePadding(str)
    return substitute(a:str,'\s\+$','','')
endfunction
