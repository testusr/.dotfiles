Clone this directory to ~/.dotfiles

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

```
.config -> ../dotfiles/nvim/.config

```

