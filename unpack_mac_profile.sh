#!/bin/bash

# USAGE: ./unpack_mac_profile.sh [des_dir]
# Script will unpack mac-specific bash and vim rc files to the specified directory.  If no dir is
# specified then the script will default to one level above the script's home directory.



SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
        # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

if [ -z "$1" ]
then
        DEST_DIR="$DIR/.."
else
        DEST_DIR="$1"
fi

# Copy files to DEST_DIR

echo "Copying MAC Profile files to $DEST_DIR"
cp $DIR/mac/.bash_aliases $DEST_DIR
cp $DIR/mac/.bash_functions $DEST_DIR
cp $DIR/mac/.bash_logout $DEST_DIR
cp $DIR/mac/.bashrc $DEST_DIR
cp $DIR/mac/.vimrc $DEST_DIR

NEW_MAC_SETUP="$DIR/mac/new_mac_setup.sh"
echo "Copying $NEW_MAC_SETUP to $DEST_DIR, if this is your first unpack on a new machine, be sure to run the script to do a lot of basic setup"
cp $NEW_MAC_SETUP $DEST_DIR

echo "Not copying $DIR/misc/backup_dir_tool.py, deploy it manually if you want to backup your local files"



echo "Done."
