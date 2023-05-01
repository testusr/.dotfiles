Cl/one this directory to ~/.dotfiles

# preparing tmux 

```
brew install tmux 
$ git clone https://github.com/tmux-plugins/tpm.git ~/.tmux/plugins/tpm
$ tmux source ~/.tmux.conf

```

[tpm - plugin manager](https://linuxhint.com/installing-plugins-tmux/)

# Using Stow 

Stow is a helper programm, supporting with keeping all dotfiles in a single
directlory and installing the as links, in target directories where the system
needs them to be. 

A command like:

```
stow -d ~/dotfiles -t ~/stow_target nvim
```

will install all files under ~/dotfiles/nvim as symlink into target directory
~/stow_target 


# Shortcuts 

## LSP 

|shorcut|action|
|-------|------|
|gf | show definitions, referemces|
|gD | go to declaration|
|gd | see definition and makes edits in window|
|gi | go to implementation | 
|<leader>vca | see available code actions | 
|<leader>vrn | smart rename | 
|<leader>vd | show diagnostics for line|
|<leader>d | show diagnostics for cursor|
|[d | jump to previos diagnostics in buffer|
|]d | jump to next diagnostics in buffer | 
|K | show documantation for what is under cursor|
|<leader> o| see outline on the right hand side | 
|<leader>ci | lspsaga incoming calls | 
|<leader>co | lspsage outgoing calls | 
|<leader>v  |  | 
|<leader>vws | | 
|<leader>vd | | 
|<leader>[d | | 
|<leader>]d | | 
|<leader>vca | | 
|<leader>vrr | | 
|<leader>vrn | | 
|<C-h> | insert mode |

## fugitive 

|shortcut|action|
|--------|------|
|<leader>gs | Git Summary / g? for mappings|

## undotree 

|shortcut|action|
|--------|------| 
|<leader>u | toggle | 

## harpoon
|shortcut|action|
|--------|------|
|<leader>a | add file|
|<C-e> | quick menu | 
|<C-[h,,t,n,s]>| file switch 1,2,3,4|

#Tmux 

|shortcut|action|
|--------|------|
|<C-a>c | new window| 
|<C-a>,  | rename window|
|<C-a>n | next windows|
|<C-a>p | previous window| 
|<C-a>w | navigate windows|
|<C-a>[number] | jump directly to window number x |
|<C-a>[ | open copy mode |
|<C-a>r | reload config | 
|<C-a>I | install plugins|

#nvim 

|command|action|
|-------|------|
|:tabnew | new blank tab|
|:gt / :tabn | next tab | 
|:gT / :tabp | previous tab| 
|[i]gt | goto tab nr [i] | 
|:tabc | close current tab | 
|:tabo | close all other tabs| 

