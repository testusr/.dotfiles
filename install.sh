#!/bin/bash

## install tmux if not already installed 
if ! [[ $(which tmux) ]] 
then 
  echo "installing tmux"
  brew install tmux
else 
  echo "tmux already installed"
fi 

if ! [[ -d "$HOME/.tmux/plugins/tpm" ]]
then 
  echo "installing tpm / tmux package manager"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else 
  echo "tpm already installed"
fi


## install configuration files via stow 

STOW_DIR=$HOME/.dotfiles; export STOW_DIR

all_stows=$(for dir in $HOME/.dotfiles/*/; do basename $dir; done) ; 
echo "found stows '$(echo $all_stows)' in '$STOW_DIR'"

for curr_stow in $all_stows; do 
  if [[ "$curr_stow" != *"_arch"* ]]; then 
    echo "stowing $curr_stow"
    stow -D $curr_stow 
    stow $curr_stow
  fi
done;

unset STOW_DIR

if [[ "$PATH" != *":$HOME/.local/bin"* ]] 
then
  echo "adding $HOME/.local/bin to PATH variable via .bash_profile"
  echo "export PATH=\$PATH:$HOME/.local/bin" >> ~/.bash_profile
  source ~/.bash_profile 
else
  echo ":$HOME/.local/bin already part of PATH"
fi


