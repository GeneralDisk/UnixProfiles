#!/bin/bash

# This scrip unpacks all vm specific bash profile files to the specified repository

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

echo "Copying VM Profile files to $DEST_DIR"
cp $DIR/vm/.bash_aliases $DEST_DIR
cp $DIR/vm/.bash_functions $DEST_DIR
cp $DIR/vm/.bash_logout $DEST_DIR
cp $DIR/vm/.bashrc $DEST_DIR
cp $DIR/vm/.vimrc $DEST_DIR
#cp -R $DIR/vm/.vim $DEST_DIR
#cp -R $DIR/vm/.ssh $DEST_DIR

cp $DIR/pack_vm_p_files.sh $DEST_DIR

echo "Done."
