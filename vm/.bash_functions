# Bash functions file
# Author: Maris Kali

TESTBED=''
PYTEST_SOURCE=":/home/mkali/fixtestenv/bin:"

#useful for debugging and testing
testF()
{
        if [[ ! ":$PATH:" == *":/home/mkali/fixtestenv/bin:"* ]]
        then
                echo "RUN VITRUTAL INSTALL YOU PLEB"
        else
                echo "Source has been set up :)"
        fi

}

# Function that allows us to copy and paste jenkins log lines and automatically find the correct
# artifact logging directory.  TODO: write in PLAN and TASK dir verification (make sure they are
# real dirs).
plog()
{
        ART_DIR="/mnt/pb/artifacts"
        ART_DEST_DIR="$ART_DIR"

        # Don't reset PLAN every run, but do reset TASK.  This allows us to save the parent
        # dir.
        TASK=''

        for var in "$@"
        do
                #echo "Splitting: $var"
                for word in $var
                do
                        if [[ "$word" =~ "plan" ]]
                        then
                                PLAN="$word"
                        fi
                        if [[ "$word" =~ "task" ]]
                        then
                                TASK="$word"
                        fi

                done
        done
        if [ -z "$PLAN" ]
        then
                echo "Notification: Plan dir not specified.  Going to parent artifact dir."
        else
                ART_DEST_DIR="$ART_DEST_DIR/$PLAN"

                if [ -z "$TASK" ]
                then
                        echo "Notification: Task dir not specified.  Going to $PLAN dir."
                else
                        ART_DEST_DIR="$ART_DEST_DIR/$TASK"
                fi
        fi

        echo "Going to directory: $ART_DEST_DIR"
        cd $ART_DEST_DIR
}

pfind()
{
        FILE_EXTENSIONS="h,cpp,py"
        CUR_DIR=$(pwd)

        if [ -z "$1" ]
        then
                echo "ERROR: Please supply an argument flag.  Type 'pfind -h' for usage."
                return 1
        else
                case "$1" in
                        -h|--help)
                                echo "*** pfind command: helper for grepping and finding ***"
                                echo " "
                                echo "pfind [option] [pattern/file]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-f, --find                find a file in sub dirs"
                                echo "-g, --grep                grep for a pattern in sub dirs"
                                echo " ******* "
                                return 0
                                ;;
                        -f|--find)
                                COMMAND_STR="find $CUR_DIR -name"
                                ;;
                        -g|--grep)
                                # For bash literal expansions, we need to eval echo and store the
                                # result
                                GLOB=--include=\*.{$FILE_EXTENSIONS}
                                GLOB_EXP=$(eval echo $GLOB)
                                COMMAND_STR="grep --color $GLOB_EXP -rnw $CUR_DIR -e"

                                # Clean the variables
                                GLOB=''
                                GLOB_EXP=''
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Pass -h for options."
                                return 1
                                ;;
                esac
        fi

        if [ -z "$2" ]
        then
                echo "ERROR: You must supply a second argument to grep or find!"
                return 1
        else
                COMMAND_STR="$COMMAND_STR $2"
                echo "Calling: $COMMAND_STR"
                $COMMAND_STR
        fi

        FILE_EXTENSIONS=''
        COMMAND_STR=''
        CUR_DIR=''
}


#function for running pytest
ptest ()
{
        if [ -z "$1" ]
        then
                echo "ERROR: You must supply an argument flag.  Type 'ptest -h' for usage."
                return 1
        else
                # TODO: change this intro a loop that scans for all option args and appends onto
                # a command string, BOOM that's gonna be sexy
                case "$1" in
                        -h|--help)
                                echo "*** ptest command: helper for running pytest ***"
                                echo " "
                                echo "ptest [option] [test file]"
                                echo " "
                                echo "NOTE: You must set the TESTBED variable to use this function."
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-s, --setup               setup/update the testbed on target array"
                                echo "-r, --run                 run regularly without setup"
                                echo "--no-io                   run regularly without IO"
                                echo "-db, --debug              run in debug mode w/ pdb"
                                return 0
                                ;;
                        -s|--setup)
                                COMMAND_STR="--testbed $TESTBED"
                                ;;
                        -r|--run)
                                COMMAND_STR="--testbed $TESTBED --test-only"
                                ;;
                        --no-io)
                                COMMAND_STR="--testbed $TESTBED --test-only --no-io"
                                ;;
                        -db|--debug)
                                COMMAND_STR="--testbed $TESTBED --test-only --pdb"
                                ;;
                        *)
                                echo "ERROR: Invalid argument flag passed.  Type 'ptest -h' for usage."
                                return 1
                                ;;
                esac
        fi

        if [ -z "$TESTBED" ]
        then
                echo "ERROR: You must set TESTBED to use this function";
                return 1
        fi

        if [ -z "$2" ]
        then
                echo "ERROR: You must supply a valid path to a pytest file."
                return 1
        else
                # rather naivee check to see if the fixtestenv has been added to the path
                if [[ ! ":$PATH:" == *"$PYTEST_SOURCE"* ]]
                then
                        virtual_install;
                fi

                echo "Calling: pytest $2 $COMMAND_STR"
                pytest $COMMAND_STR "$2"
        fi

        #virtual_uninstall; #activate this if you want to hide the sourcing agent
}
