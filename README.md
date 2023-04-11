Clone this directory to ~/.dotfiles

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

```
.config -> ../dotfiles/nvim/.config

```

