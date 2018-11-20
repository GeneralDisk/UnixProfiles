#!/bin/bash

# Packs all vm profile files back into the UnixProfiles repo

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"
        SOURCE="$(readlink "$SOURCE")"
        [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
        # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null && pwd )"

# Find the UnixProfiles repo

cd

REPO_DIR="$(find . -name UnixProfiles)"

# Copy files into repo directory

DEST_DIR="$REPO_DIR/vm"

echo "Copying VM Profile files to $DEST_DIR"

cp $DIR/.bash_aliases $DEST_DIR
cp $DIR/.bash_functions $DEST_DIR
cp $DIR/.bash_logout $DEST_DIR
cp $DIR/.bashrc $DEST_DIR
cp $DIR/.vimrc $DEST_DIR
cp -R $DIR/.vim $DEST_DIR
#cp -R $DIR/.ssh $DEST_DIR

echo "Done."
