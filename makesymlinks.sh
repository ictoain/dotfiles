#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################

########## Variables

dir=~/.dotfiles                    # dotfiles directory
olddir=~/.dotfiles_old             # old dotfiles backup directory
#files="bashrc vimrc vim zshrc oh-my-zsh private scrotwm.conf Xresources"    # list of files/folders to symlink in homedir
files="bashrc vimrc zshrc screenrc screen oh-my-zsh"
configfiles="awesome"

##########

# create dotfiles_old in homedir
if [ ! -d $olddir ];then
  echo -n "Creating $olddir for backup of any existing dotfiles in ~ ..."
  mkdir -p $olddir
  echo "done"
fi

# change to the dotfiles directory
echo -n "Changing to the $dir directory ..."
cd $dir
echo "done"

echo -n "Pulling dotfiles repo..."
git pull
echo "done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create 
#symlinks from the homedir to any files in the ~/dotfiles directory specified
#in $files
for file in $files; do
  if [ ! -L ~/.$file ]&&[ -f ~/.$file -o -d ~/.$file ];then
    echo "Moving existing dotfile $file from ~ to $olddir"
    mv ~/.$file $olddir
  fi
  if [ ! -L ~/.$file ];then
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/.$file
  fi
done
for file in $configfiles; do
  if [ ! -L ~/.config/$file ]&&[ -f ~/.config/$file -o -d ~/.config/$file ];then
    echo "Moving existing conffile .config/$file from ~ to $olddir"
    mv ~/.config/$file $olddir
  fi
  if [ ! -L ~/.config/$file ];then
    echo "Creating symlink to config/$file in home directory."
    ln -s $dir/$file ~/.config/$file
  fi
done


install_zsh () {
# Test to see if zshell is installed.  If it is:
if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
    # Clone my oh-my-zsh repository from GitHub only if it isn't already present
    if [[ ! -f $dir/oh-my-zsh/oh-my-zsh.sh ]]; then
        rm -r $dir/oh-my-zsh
        git clone http://github.com/robbyrussell/oh-my-zsh.git
    fi
    # Set the default shell to zsh if it isn't currently set to zsh
    if [[ ! $(echo $SHELL) == $(which zsh) ]]; then
        chsh -s $(which zsh)
    fi
else
    # If zsh isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install zsh and then recurse
    if [[ $platform == 'Linux' ]]; then
        sudo apt-get install zsh
        install_zsh
    # If the platform is OS X, tell the user to install zsh :)
    elif [[ $platform == 'Darwin' ]]; then
        echo "Please install zsh, then re-run this script!"
        exit
    fi
fi
}

install_screen () {
# Test to see if screen is installed.  If it is not:
if [ ! -f /usr/bin/screen -a ! -f /bin/screen ]; then
    # If screen isn't installed, get the platform of the current machine
    platform=$(uname);
    # If the platform is Linux, try an apt-get to install screen and then recurse
    if [[ $platform == 'Linux' ]]; then
        sudo apt-get install screen
        install_screen
    # If the platform is OS X, tell the user to install screen :)
    elif [[ $platform == 'Darwin' ]]; then
        echo "Please install screen, then re-run this script!"
        exit
    fi
fi
}

install_zsh
install_screen
