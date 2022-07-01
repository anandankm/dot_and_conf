#!/bin/bash

if [[ -z $1 ]]
then
    TMUX_VERSION="3.3a"
else
    TMUX_VERSION=$1
fi

sudo yum install -y libevent ncurses libevent-devel ncurses-devel

wget https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz

tar -zxf tmux-$TMUX_VERSION.tar.gz
cd tmux-$TMUX_VERSION/
./configure
make && sudo make install
