#!/bin/bash

DIR="/Users/mkali"

REPO_DIR="$DIR/UnixProfiles"
echo "This script assumes that the UnixProfiles directory exists at $REPO_DIR!"

# Copy files into repo directory

DEST_DIR="$REPO_DIR/mac"

echo "Copying MAC Profile files to $DEST_DIR"

cp $DIR/.bash_aliases $DEST_DIR
cp $DIR/.bash_functions $DEST_DIR
cp $DIR/.bash_profile $DEST_DIR
cp $DIR/.bashrc $DEST_DIR
cp $DIR/.vimrc $DEST_DIR
#cp -R $DIR/.vim $DEST_DIR
#cp -R $DIR/.ssh $DEST_DIR
echo "Copying MAC .ssh config file (id and key files ignored for obvious reasons)"
cp $DIR/.ssh/config $DEST_DIR/.ssh/config

echo "NOTE: This script does not run the backup_dir script, please refer to the README for more info"
echo "Done."
