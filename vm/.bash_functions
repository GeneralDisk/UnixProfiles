# Bash functions file
# Author: Maris Kali

TESTBED=''
PYTEST_SOURCE=":/home/mkali/fixtestenv/bin:"

testDUMB()
{
        echo "This"
        echo "is"
        echo "a bunch"
        echo "of crap heyyyyyy"
}

#useful for debugging and testing
testF()
{
        #if [[ ! ":$PATH:" == *":/home/mkali/fixtestenv/bin:"* ]]
        #then
        #        echo "RUN VITRUTAL INSTALL YOU PLEB"
        #else
        #        echo "Source has been set up :)"
        #fi
        #
        #
        line="==  FAILED  ==     4996 ms --  task-a72b4953  -- worker-9f91cdd9 -- ha.multipath.change_drive_active_path"
        file="${line##* }^[[om"
        file=${file%^*}
        echo $file
}

gdiff()
{
        echo "Comparing local branch to upstream.\nIf you are rebasing, there should be no lines <\n"
        echo "Calling: diff <(git log --oneline HEAD..@{u}| cut -d ' ' -f 2-) <(git log --oneline @{u}..HEAD | cut -d ' ' -f 2-)"

        diff <(git log --oneline HEAD..@{u}| cut -d ' ' -f 2-) <(git log --oneline @{u}..HEAD | cut -d ' ' -f 2-)
}

# do_debug.py helper function.  Uses separate git repo for do_debug and routes to correct python script
do_debug()
{

        # USAGE:
        # usually use with a -u flag with a jenkins link to examine core files
        # Ex: do_debug -u http://mp2jenkins.dev.purestorage.com:8080/job/mergepool_trunk_network_vlan_functional_test/1767/

        PURE_TOOLS_REPO="/home/mkali/work/purity/tools/pure_tools/"
        GIT_REPO="/home/mkali/work/purity_debug/purity"
        WORKDIR="/home/mkali/work/do_debug"

        case $PWD in $WORKDIR/*)
                echo "Using working directory $PWD";;
                *)
                cd $WORKDIR;;
        esac
        exec "$PURE_TOOLS_REPO/debug/do_debug.py" -g "$GIT_REPO" "$@"

        PURE_TOOLS_REPO=''
        GIT_REPO=''
        WORKDIR=''

}

# Utility for compiling and sending purity libraries to a target array
update_libs()
{
        CUR_TIME=$(date +'%Y-%m-%d %T')
        # Master list of all purity development libraries.  Update when necessary.
        ALL_LIBS_ARRAY=( "admin" "bdev" "bmc" "boost" "bootcamp" "boot" "cdu" "cert" "chassis_mgr_gen" "cluster" "cpu"
                         "crc32" "crypto" "curl" "defs" "ds" "fmm" "foe" "fpl" "ha" "hardware_config"
                         "header" "homestake_hw" "hw" "i2c" "ipmioem" "jsoncpp" "killswitch-svc" "log"
                         "lz4" "lzopro" "malloc2.13" "mgmt" "middleware" "middleware_platform" "network"
                         "ntp" "offload" "osenv" "platinum_hw" "portinfo_common" "port_migration" "pureapp"
                         "pyplatform" "random" "replication" "reset" "s3" "san2" "san" "secret" "segmap"
                         "sha" "smis" "snmp" "sql" "storage" "svc" "tbl" "tc" "vol" "xmlrpc" "z" "zstd" )

        if [ -z "$1" ]
        then
                #PB_TEST=''
                echo "ERROR: Please supply an argument flag.  Type 'update_libs -h' for usage."
                return 1
        else
                case "$1" in
                        -h|--help)
                                echo "*** update_libs command: helper function for compiling and sending libs to a target array ***"
                                echo " "
                                echo "update_libs [option] [arg(s)]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-t, --testbed             set the target testbed array"
                                echo "-v, --vim                 send vimrc to target array"
                                echo "-a, --all                 update all purity libraries.  This option takes a while."
                                echo "-s, --specific-lib        update specific libraries. (for ex: 'hw ha')"
                                echo " ******* "
                                return 0
                                ;;
                        -t|--testbed)
                                # TODO Implement this yo
                                if [ -z "$2" ]
                                then
                                        if [ -z "$TARGET_ARRAY" ]
                                        then
                                                echo "Please provide an array to update."
                                                return 1
                                        fi
                                        echo "Current target array is $TARGET_ARRAY"
                                        return 0
                                fi
                                TARGET_ARRAY="$2"
                                TARGET_ARRAY=${TARGET_ARRAY#"lp-"}

                                echo "Setting target testbed array to $TARGET_ARRAY"
                                return 0
                                ;;
                        -v|--vim)
                                send_vimrc "$TARGET_ARRAY"
                                return 0
                                ;;
                        -a|--all)
                                LIBS_ARRAY=("${ALL_LIBS_ARRAY[@]}")
                                ;;
                        -s|--specific-lib)
                                if [ -z "$2" ]
                                then
                                        echo "Please provide a specific library to update."
                                        return 1
                                else
                                        LIBS_ARRAY=()
                                        # iterate through all arguments after the first
                                        for lib in "${@:2}"
                                        do
                                                # Verify lib is a valid choice
                                                if [[ " ${ALL_LIBS_ARRAY[@]} " =~ " ${lib} " ]]
                                                then
                                                        echo "updating $lib"
                                                        LIBS_ARRAY+=("$lib")
                                                else
                                                        echo "NOTE: $lib is not a valid library name"
                                                fi
                                        done
                                        lib=''
                                fi
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Pass -h for options."
                                return 1
                                ;;
                esac
        fi

        echo "Starting at $CUR_TIME"
        make_libs
        send_libs
        LIBS_ARRAY=''
        ALL_LIBS_ARRAY=''
        #TARGET_ARRAY=''
}

make_libs()
{
        # To change make optimization flags goto purity base directory and run
        # ppremake.sh with the desired flags.
        # Ex: ./ppremake.sh --cc=gcc --optimize=3
        # TODO: make this into it's own separate cmd option?
        if [ -z "$LIBS_ARRAY" ]
        then
                echo "No libs array provided, compiling the default list"
                LIBS_ARRAY=( "ha" "hw" "bdev" "storage" "reset" "header" )
                CLEAN="true"
        fi


        LIB_OUTPUT_DIR="/home/mkali/work/bld_linux/purity/"

        for CUR_LIB in "${LIBS_ARRAY[@]}"
        do
                TARGET_LIB="$CUR_LIB-Release"
                echo "Compiling: $TARGET_LIB"
                CMD="ninja -j 10 -C $LIB_OUTPUT_DIR $TARGET_LIB"

                # echo " - $CMD"
                $CMD
        done

        echo "Done compiling all libraries"

        if [[ $CLEAN == "true" ]]
        then
                LIBS_ARRAY=''
        fi
        CUR_LIB=''
        TARGET_LIB=''
        CMD=''
        CLEAN=''
}

send_libs()
{

        #if [ -z "$1" ]
        #then
                #PB_TEST=''
        #        echo "ERROR: Please supply a target array"
        #        return 1
        #fi
        if [ -z "$TARGET_ARRAY" ]
        then
                echo "ERROR: TARGET_ARRAY variable must be set"
                return 1
        fi

        if [ -z "$LIBS_ARRAY" ]
        then
                echo "No libs array provided, sending default list"
                CLEAN="true"
                LIBS_ARRAY=( "ha" "hw" "bdev" "storage" "reset" "header" )
        fi
        #TARGET_ARRAY="jm69-24"

        TARGET_LIB_DIR="/opt/Purity/lib"
        SOURCE_LIB_DIR="/home/mkali/work/bld_linux/purity/lib"

        # Remove lp- if it was input
        TARGET_ARRAY=${TARGET_ARRAY#"lp-"}

        CONTROLLER_0="$TARGET_ARRAY-ct0"
        CONTROLLER_1="$TARGET_ARRAY-ct1"

        for CUR_LIB in "${LIBS_ARRAY[@]}"
        do
                TARGET_FILE="lib$CUR_LIB.so"
                echo "Sending '$TARGET_FILE' to '$CONTROLLER_0' and '$CONTROLLER_1'"
                CMD_1="scp $SOURCE_LIB_DIR/$TARGET_FILE root@$CONTROLLER_0:$TARGET_LIB_DIR"
                CMD_2="scp $SOURCE_LIB_DIR/$TARGET_FILE root@$CONTROLLER_1:$TARGET_LIB_DIR"

                echo "Calling: $CMD_1"
                echo "Calling: $CMD_2"
                $CMD_1
                $CMD_2
        done

        echo "Done."

        if [[ "$CLEAN" == "true" ]]
        then
                LIBS_ARRAY=''
        fi
        CLEAN=''
        CUR_LIB=''
        TARGET_FILE=''
        #TARGET_ARRAY=''
        CONTROLLER_0=''
        CONTROLLER_1=''
}

send_vimrc()
{
        if [ -z "$1" ]
        then
                #PB_TEST=''
                echo "ERROR: Please supply a target array"
                return 1
        fi

        TARGET_FILE=".array_vimrc"
        DEST_ARRAY="$1"

        # Remove lp- if it was input
        DEST_ARRAY=${DEST_ARRAY#"lp-"}

        CONTROLLER_0="$DEST_ARRAY-ct0"
        CONTROLLER_1="$DEST_ARRAY-ct1"


        echo "Sending '$TARGET_FILE' to '$CONTROLLER_0' and '$CONTROLLER_1'"

        CMD_1="scp /home/mkali/$TARGET_FILE root@$CONTROLLER_0:/root/.vimrc"
        CMD_2="scp /home/mkali/$TARGET_FILE root@$CONTROLLER_1:/root/.vimrc"

        # echo "Calling: $CMD_1"
        $CMD_1

        # echo "Calling: $CMD_2"
        $CMD_2


        echo "Done."

        TARGET_FILE=''
        DEST_ARRAY=''
        CONTROLLER_0=''
        CONTROLLER_1=''
}

# Function that runs pb and will automatically open the log output if a test fails
run()
{
        # TODO: make options for opening error file & using non-interactive mode.
        # TODO: write checks for compiler errors, only execute opening step if a valid file is pulled
        # TODO: add option to specify PB_TESTvariable, either as env var or as option
        lines=()
        # PB_TEST='ha.multipath'
        CUR_TIME=$(date +'%Y-%m-%d %T')

        if [ -z "$1" ]
        then
                #PB_TEST=''
                echo "ERROR: Please supply an argument flag.  Type 'run -h' for usage."
                return 1
        else
                case "$1" in
                        -h|--help)
                                echo "*** run command: helper function for running pb run ***"
                                echo " "
                                echo "run [option]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-r, --run                 run pb build command normally"
                                echo "-o, --open                open failed test stdout files if any"
                                echo "-t, --test [arg]          display current PB_TEST value or set if arg input"
                                echo " ******* "
                                return 0
                                ;;
                        -r|--run)
                                RUN_PB_NORMALLY='true'
                                ;;
                        -o|--open)
                                ;;
                        -t|--test)
                                if [ -z "$2" ]
                                then
                                        echo "Current PB_TEST is '$PB_TEST'"
                                else
                                        echo "Setting PB_TEST to '$2'"
                                        PB_TEST="$2"
                                fi

                                return 0
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Pass -h for options."
                                return 1
                                ;;
                esac
        fi

        if [ -z "$PB_TEST" ]
        then
                #echo "ERROR: You must set PB_TEST to use this function";
                #return 1
                PB_TEST=""
        fi

        # set_pb_vars  Not sure why this isn't working... fucking aliases

        echo "Running at $CUR_TIME"

        if [[ "$RUN_PB_NORMALLY" == "true" ]]
        then
                COMMAND="pb run runtests $PB_TEST"
                echo "Running command '$COMMAND'"

                $COMMAND
                RUN_PB_NORMALLY=''
                return 0
        fi


        PLAN=""
        TASK=""

        set +m # disable job controle to allow lastpipe
        shopt -s lastpipe

        COMMAND="pb --non-interactive run runtests $PB_TEST"

        echo "Running command '$COMMAND'"

        #ALL_OUTPUT=$(eval $COMMAND 2>&1)
        OPEN_LOG_FILE="false"
        TEST_CASE=""
        # 2>&1 grabs all stdout and stderr output
        $COMMAND 2>&1 | {
                while IFS= read -r line
                do
                        printf "%s\n" "$line"
                        for word in $line
                        do
                                if [[ "$word" =~ "plan" ]]
                                then
                                        PLAN="$word"
                                fi
                                if [[ "$word" =~ "task" ]]
                                then
                                        TASK="$word"
                                fi
                                if [[ "$word" =~ "FAILED" ]]
                                then
                                        OPEN_LOG_FILE="true"
                                        TEST_CASE="${line##* }"
                                        TEST_CASE=${TEST_CASE%^*}
                                fi
                        done

                done
        }
        echo "Finished"
        #echo $ALL_OUTPUT
        #echo "Pulled plan: $PLAN"
        #echo "Pulled task: $TASK"
        #echo "Pulled failed testcase: $TEST_CASE"

        LOG_FILE="$PLAN/${TEST_CASE}__${TASK}__failed.stdout"
        if [[ "$OPEN_LOG_FILE" = true ]]
        then
                echo "Opening log file: $LOG_FILE"
                vi $LOG_FILE
        fi
        #ALL_OUTPUT=()
}

# Function that allows us to copy and paste jenkins log lines and automatically find the correct
# artifact logging directory.  TODO: write in PLAN and TASK dir verification (make sure they are
# real dirs).
plog()
{
        ART_DIR="/mnt/cluster_nfs" #"/mnt/pb/artifacts" for jenkins logs
        ART_DEST_DIR="$ART_DIR"

        CUR_TEST=''
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


        # uncomment this if you want to do jenkins logs w/ artifacts TODO: make options for both
        # echo "Going to directory: $ART_DEST_DIR"
        # cd $ART_DEST_DIR
        CUR_TEST="ha.multipath.change_drive_active_path"

        ERROR_FILE="${CUR_TEST}__${TASK}__failed.stdout"

        ART_DEST_DIR="$ART_DIR/$PLAN/$ERROR_FILE"
        echo "Opening stdout file for failed test: $ART_DEST_DIR"
        vi $ART_DEST_DIR
}

# Function to open remote logs from specified ssh target
rlog()
{
        REMOTE_LOG_DIR='/var/log/purity'
        REMOTE_CONTROLLER=''
        REMOTE_TARGET_FILE=''

        if [ -z "$1" ]
        then
                echo "ERROR: Please supply an argument flag.  Type 'rlog -h' for usage."
                return 1
        else
                case "$1" in
                        -h|--help)
                                echo "*** rlog command: helper for opening remote logs from a specified ssh target ***"
                                echo " "
                                echo "rlog [option(s)] [args]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-t, --target              show current remote target or [arg] set one"
                                echo "-o, --open                open [arg] logfile from [arg] specified controller"
                                echo "-p, --platform            open platform.log from [arg] specified controller"
                                echo "-s, --syslog              open syslog from [arg] specified controller"
                                return 0
                                ;;
                        -t|--target)
                                if [ -z "$2" ]
                                then
                                        if [ -z "$REMOTE_TARGET" ]
                                        then
                                                echo "Please provide a valid target array."
                                                return 1
                                        fi
                                        echo "Current target array is $REMOTE_TARGET"
                                        return 0
                                fi
                                REMOTE_TARGET="$2"
                                REMOTE_TARGET=${REMOTE_TARGET#"lp-"}

                                echo "Setting target testbed array to $REMOTE_TARGET"
                                return 0
                                ;;
                        -o|--open)
                                if [ -z "$2" ]
                                then
                                        echo "ERROR: Please provide a target file"
                                else
                                        REMOTE_TARGET_FILE="$2"
                                fi

                                if [ -z "$3" ]
                                then
                                        echo "ERROR: Please provide a target controller"
                                        return 1
                                else
                                        REMOTE_CONTROLLER="$3"
                                fi
                                ;;
                        -p|--platform)
                                REMOTE_TARGET_FILE="platform.log.gz"
                                if [ -z "$2" ]
                                then
                                        echo "ERROR: Please provide a target controller"
                                        return 1
                                else
                                        REMOTE_CONTROLLER="$2"
                                fi
                                ;;
                        -s|--syslog)
                                REMOTE_TARGET_FILE="../syslog"
                                if [ -z "$2" ]
                                then
                                        echo "ERROR: Please provide a target controller"
                                        return 1
                                else
                                        REMOTE_CONTROLLER="$2"
                                fi
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Pass -h for options."
                                return 1
                                ;;
                esac
        fi

        # Allow for two options to assign ct0
        if [ \( "$REMOTE_CONTROLLER" == "0" \) -o \( "$REMOTE_CONTROLLER" == "ct0" \) ]
        then
                REMOTE_CONTROLLER="-ct0"
        fi

        # Allow for two options to assign ct1
        if [ \( "$REMOTE_CONTROLLER" == "1" \) -o \( "$REMOTE_CONTROLLER" == "ct1" \) ]
        then
                REMOTE_CONTROLLER="-ct1"
        fi

        # Bark about bad input
        if [ \( "$REMOTE_CONTROLLER" != "-ct0" \) -a \( "$REMOTE_CONTROLLER" != "-ct1" \) ]
        then
                echo "ERROR: [ $REMOTE_CONTROLLER ] is a bad input for controller target.  Specify '0, ct0' or '1, ct1' for controls 0 and 1 respectively"
                return 1
        fi

        #ssh root@d107-3-ct0 'zcat /var/log/purity/platform.log.gz' | vi -
        COMMAND="ssh root@$REMOTE_TARGET$REMOTE_CONTROLLER 'zcat $REMOTE_LOG_DIR/$REMOTE_TARGET_FILE' | vi -"

        echo "Calling: $COMMAND"

        eval $COMMAND

        COMMAND=''
        REMOTE_CONTROLLER=''
        REMOTE_LOG_DIR=''
        REMOTE_TARGET_FILE=''
}

pfind()
{
        FILE_EXTENSIONS="h,cpp,py"
        CUR_DIR=$(pwd)
        OPEN_FILE=false

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
                                echo "-o, --open                open a file if it exists in sub dirs"
                                echo "-g, --grep                grep for a pattern in sub dirs"
                                echo "-gl                       grep for a pattern in .log files"
                                echo "-gc                       grep for a pattern in .config files"
                                echo " ******* "
                                return 0
                                ;;
                        -f|--find)
                                COMMAND_STR="find $CUR_DIR -name"
                                ;;
                        -o|--open)
                                COMMAND_STR="find $CUR_DIR -name"
                                OPEN_FILE=true
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
                        -gl)
                                # For bash literal expansions, we need to eval echo and store the
                                # result
                                FILE_EXTENSIONS+=",log"
                                GLOB=--include=\*.{$FILE_EXTENSIONS}
                                GLOB_EXP=$(eval echo $GLOB)
                                COMMAND_STR="grep --color $GLOB_EXP -rnw $CUR_DIR -e"

                                # Clean the variables
                                GLOB=''
                                GLOB_EXP=''
                                ;;
                        -gc)
                                # For bash literal expansions, we need to eval echo and store the
                                # result
                                FILE_EXTENSIONS+=",config"
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
                # For grepping multiple patterns recursively, remove the eval and quotes
                # Format command string to quote the user input
                COMMAND_STR="$COMMAND_STR \"$2\""

                if [ "$OPEN_FILE" = true ]
                then
                        echo "Calling: $COMMAND_STR"
                        CMD_RES="$(eval $COMMAND_STR)"

                        if [ -z "$CMD_RES" ]
                        then
                                echo "No results found for search pattern."
                                return 0
                        fi

                        # scan to line impl
                        # TODO: make this an option flag you pleb, 'ol' maybe
                        if [ -z "$3" ]
                        then
                                OPEN_SPEC_LINE='false'
                        else
                                # Make sure input is valid
                                SPEC_LINE="$3"
                                if [[ -n ${SPEC_LINE//[0-9]/} ]]
                                then
                                        echo "Bad line number specified, opening file at ln: 1"
                                        OPEN_SPEC_LINE='false'
                                else
                                        OPEN_SPEC_LINE='true'
                                fi
                        fi

                        # TODO: implement version of this that opens line of grep readout! That would be baller as fuck.
                        # Use input scanner to parse the grep result into an array
                        IFS=$'\n'; FILES=($CMD_RES); unset IFS;

                        # Open the file if only one result, ask the user which to open if more
                        if [ ${#FILES[@]} == "1" ]
                        then
                                OPEN_FILE="$FILES"
                        else
                                echo "${#FILES[@]} files found with name $2:"
                                counter=1
                                COLOR_CODE=31
                                for fl in "${FILES[@]}"; do
                                        echo -e "\e[${COLOR_CODE}m[$counter] $fl"
                                        (( counter++ ))
                                        (( COLOR_CODE++ ))
                                        if [[ $COLOR_CODE -gt 36 ]]
                                        then
                                                COLOR_CODE=31
                                        fi
                                done
                                COLOR_CODE=''
                                echo -en "\e[0mType the index of the one you want to open and press [ENTER]: "
                                read choice

                                # Check to see if input is valid.  First check that it's a number
                                if [[ -n ${choice//[0-9]/} ]]
                                then
                                        echo "Invalid input, use only numbers."
                                        return 1
                                else
                                        # Now check that the input is in the valid range of choices
                                        if [ $choice -lt 1 ] || [ $choice -gt ${#FILES[@]} ]
                                        then
                                                echo "Invalid input, input out of range"
                                                return 1
                                        fi
                                fi
                                # Convert to array index and assign
                                (( choice-- ))

                                OPEN_FILE="${FILES[choice]}"
                        fi

                        if [ $OPEN_SPEC_LINE == 'true' ]
                        then
                                echo "Opening file: $OPEN_FILE at line $SPEC_LINE"
                                COMMAND_STR='vi $OPEN_FILE +$SPEC_LINE'
                                eval $COMMAND_STR
                        else
                                echo "Opening file: $OPEN_FILE"
                                vi "$OPEN_FILE"
                        fi
                else
                        # Grepping patterns, support extra args
                        echo "Calling: $COMMAND_STR ${@:3}"
                        eval $COMMAND_STR ${@:3}
                fi
        fi

        FILE_EXTENSIONS=''
        COMMAND_STR=''
        CUR_DIR=''
        OPEN_FILE=''
        CMD_RES=''
        OPEN_SPEC_LINE=''
        SPEC_LINE=''
        return 0
}


#function for running pytest
ptest ()
{

        requires_file=true
        SETUP_TB_FILE_LOC="/home/mkali/work/purity/tools/tests/infra/ci/setup_testbed.py"


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
                                echo "-rf, --refresh            run ssd reset on the testbed"
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
                        -rf|--refresh)
                                COMMAND_STR="$SETUP_TB_FILE_LOC --testbed $TESTBED --reset --skip-update"
                                requires_file=false
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

        # if no file was required, this is a maintance command
        if [ "$requires_file" = false ]
        then
                # rather naivee check to see if the fixtestenv has been added to the path
                if [[ ! ":$PATH:" == *"$PYTEST_SOURCE"* ]]
                then
                        virtual_install
                        #virtual_install_new
                fi

                echo "Calling: pytest $COMMAND_STR"
                pytest $COMMAND_STR

                return 0
        fi

        # Check that a file exists and execute the pytest command
        if [ -z "$2" ]
        then
                echo "ERROR: You must supply a valid path to a pytest file."
                return 1
        else
                # rather naivee check to see if the fixtestenv has been added to the path
                if [[ ! ":$PATH:" == *"$PYTEST_SOURCE"* ]]
                then
                        virtual_install;
                        #virtual_install_new
                fi

                echo "Calling: pytest $2 $COMMAND_STR"
                eval pytest "$2" $COMMAND_STR
        fi

        #virtual_uninstall; #activate this if you want to hide the sourcing agent
}
