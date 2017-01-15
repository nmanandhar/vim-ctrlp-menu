  # vim-ctrlp-menu
CtrlP Extension that allows adding custom menus of commands

We usually have a bunch of useful commands, but don't want to create a mapping for each of them.. Instead of a host of key mappings and commands and remembering them all, wouldn't it be more useful to have a single mapping/command for all the other commands?

Vim-Ctrp-Menu is a CtrlP extention that attempts to solve this problem by allowing you to create your own custom menu of commands. You can create as many menus as you like  and you get all the goodness that Ctrp provides like fuzzy matching.

 ![ctrlp-menu](https://cloud.githubusercontent.com/assets/9746042/21963711/7e39a7e8-db67-11e6-9eb9-d1d99f984059.gif)

## Prerequisite
You need to have [CtrlP](https://github.com/ctrlpvim/ctrlp.vim) installed before you can use this plugin

## Installation

### Using Pathogen
    cd ~/.vim/bundle
    git clone https://github.com/nmanandhar/vim-ctrlp-menu.git 

## Defining Menus

This plugin uses the variable `g:ctrlp_menus` to define the menu. This variable should
be initialized in your vimrc to be a dictionary of menus

Structure of g:ctrp_menu_menus
```
let g:ctrlp_menus= {
            \    "myMenuGroup1": {
            \        "command1 for myMenuGroup1": 'echom "command1 of myMenuGroup1 executed"',
            \        "command2 for myMenuGroup1": 'echom "command2 of myMenuGroup1 executed"'
            \    },
            \    "myMenuGroup2": {
            \        "command1 for myMenuGroup2": 'echom "command1 of myMenuGroup2 executed"',
            \        "command2 for myMenuGroup2": 'echom "command2 of myMenuGroup2 executed"'
            \    }
            \}
```

Alternately, you can defined the same thing using a different syntax

```
let g:ctrlp_menus={}

let g:ctrlp_menus.myMenuGroup1=
            \{
            \   "command1 for myMenuGroup1": 'echom "command1 of myMenuGroup1 executed"',
            \   "command2 for myMenuGroup1": 'echom "command2 of myMenuGroup1 executed"'
            \}

let g:ctrlp_menus.myMenuGroup1={
            \   "command1 for myMenuGroup2": 'echom "command1 of myMenuGroup2 executed"',
            \   "command2 for myMenuGroup2": 'echom "command2 of myMenuGroup2 executed"'
            \}
```

Personally I prefer the second syntax because each menu group is defined separately.Note if your menu
group has a space in between, you will have to use the bracket notation
```
let g:ctrlp_menus["my menu group one "]={ ...
```

Once the menu is defined and sourced, you can use CtrlpMenu command. By
default this command will combine all the commands and show them in CtrlP.
If you pass in the menu group, it will show only commands in that group.

Note in CommandMode, you also get completion of the MenuName. Press CtrlpMenu
followed by space followed by tab to get completion of menu names

### Disabling the default menu
This plugin adds a default menu called default_menu. To disable this simply put the following in your vimrc
```
let g:ctrlp_use_default_menu = 0
```

### Mappings
By default, no mappings are provided. However it is recommened that you have a mapping to open up
the menus, since it is faily tedious to type CtrlpMenu on the command line

You can put something like the following in your vimrc file
```
nnoremap <leader>m :CtrlpMenu<cr>
```
Since no menu group was passed, it will show all the commands in your menues.


Another possibility would be to use abbreviation in command mode to shorten the command
```
cabbrev menu CtrlpMenu
```



