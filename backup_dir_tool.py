#!/bin/bash
# Usage: place in directory that you want to backup and run.  That's it.
# This tool will copy all files in it's cur dir, create a backup zip and send that to a destination
# vm


CUR_DIR=$(pwd)
CUR_TIME=$(date +'%Y-%m-%d-%T')

DEST_FILE="backup_$CUR_TIME.zip"
echo "Packing all files from $CUR_DIR into $DEST_FILE"

zip -r $DEST_FILE *.pages *.numbers *.sh *.sql

echo "Done"

echo "Now sending to vm"

cp "$DEST_FILE" "backup.zip"

scp "backup.zip" vm:/home/mkali/backup/

rm backup.zip

echo "Done"

CUR_TIME=''
DEST_FILE=''
