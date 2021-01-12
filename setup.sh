#!/bin/bash

DOT_FILES=(.tmux-rename-session .tmux.conf .vimrc)

for file in ${DOT_FILES[@]}; do
  if [ -e $HOME/$file ]; then
    continue
  fi
  ln -s $HOME/dotfiles/$file $HOME/$file
done