#!/bin/bash

echo "Starting new mac setup"
cd

echo "** FINISH ** Unpacking mac files"
# Run unpacking cmds here

echo "Changing default terminal to bash from zsh"
chsh -s /bin/bash

echo "** FINISH ** Installing default terminal profile"
# Terminal profile -- maybe make this automatically part of the mac backup script?

echo "Installing utilities"

echo " - Installing Brew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo " - Installing wget"
brew install wget

echo " - brew install cmake"
brew install cmake

echo " - Installing macvim"
brew install macvim
#brew install macvim --with-override-system-vim

echo "Installing VIM plugins"
vim +PluginInstall +qall
mvim -v +PluginInstall +qall

echo " - compiling ycm"
python ~/.vim/bundle/YouCompleteMe/install.py

# **** EXTRA look up moving all the mac mail files

echo "Automatic mail migration not supported."
echo "To migrate mail, plz move rules plists from the library/mail dir (use cmd + shift + . to view)"
echo ""


echo "Automatic middleware dev setup"
echo "**** Make sure you clone your purity repo! use 'git clone ssh://git.dev.purestorage.com/repos/purity.git' ****"
echo "Installing necessary pkgs via brew"
echo " -installing jdk8"
brew install --cask homebrew/cask-versions/adoptopenjdk8

echo " - installing insomnia"
brew install --cask insomnia
#echo " - installing iterm2" # optional
#brew install --cask iterm2
echo " - installing node js"
brew install node
echo " - installing maven"
brew install maven
echo " - installing intellij"
brew install --cask intellij-idea-ce
