# Bash functions file
#
# Author: Maris Kali
# Copyright: You steal my shit without asking and I will fuck you up.  All rights reserved.

TESTBED=''
PYTEST_SOURCE=":/home/mkali/fixtestenv/bin:"

list_global_vars()
{
        echo "Global terminal variables used to persist information over multiple command"

        GLOBAL_ARR=()
        GLOBAL_ARR+=("TARGET_ARRAY: [$TARGET_ARRAY] used for update_libs")
        GLOBAL_ARR+=("REMOTE_TARGET: [$REMOTE_TARGET] used for rlog")
        GLOBAL_ARR+=("PB_TEST: [$PB_TEST] used for run")
        GLOBAL_ARR+=("TESTBED: [$TESTBED] used for ptest")

        # TARGET_ARRAY # for update_libs
        # REMOTE_TARGET # for rlog
        # PB_TEST # for run
        # TESTBED # For ptest

        for var in "${GLOBAL_ARR[@]}"; do
                echo "- $var"
        done

        var=''
        GLOBAL_ARR=''
}

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
        echo "test parse 'http://repjenkins.dev.purestorage.com:8080/job/nearsync_cli-test3/77/'"
        STR='http://repjenkins.dev.purestorage.com:8080/job/nearsync_cli-test3/77/'

        IFS='/' read -ra SLASHES <<< "$STR"

        # Scan the url and grab the information we want
        found_job="false"
        for sub in "${SLASHES[@]}"; do
                if [[ $sub == *"jenkins"* ]]
                then
                        T_JENKINS="$sub"
                fi
                if [[ -n $T_JOB ]]
                then
                        T_RUN="$sub"
                fi

                if [[ $found_job == "true" ]]
                then
                        T_JOB="$sub"
                fi

                if [[ $sub == "job" ]]
                then
                        found_job="true"
                else
                        found_job="false"
                fi

                echo "$sub"
        done
        # fix the jenkins line
        IFS="." read -ra JEN <<< "$T_JENKINS"
        T_JENKINS="${JEN[0]}"

        echo "T_JENKINS = $T_JENKINS"
        echo "T_JOB = $T_JOB"
        echo "T_RUN = $T_RUN"
        T_JENKINS=''
        T_JOB=''
        T_RUN=''
        JEN=''
        SLASHES=''
        found_job=''
        #if [[ ! ":$PATH:" == *":/home/mkali/fixtestenv/bin:"* ]]
        #then
        #        echo "RUN VITRUTAL INSTALL YOU PLEB"
        #else
        #        echo "Source has been set up :)"
        #fi
        #
        #
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
                                echo "-l, --list                list available libraries"
                                echo "-t, --testbed             set the target testbed array"
                                echo "-v, --vim                 send vimrc to target array"
                                echo "-a, --all                 update all purity libraries.  This option takes a while."
                                echo "-s, --specific-lib        update specific libraries. (for ex: 'hw ha')"
                                echo " ******* "
                                return 0
                                ;;
                        -l|--list)
                                echo "Libraries available to compile:"
                                # Print all available libraries in ALL_LIBS_ARRAY
                                for lib in "${ALL_LIBS_ARRAY[@]}"
                                do
                                        echo "  -- $lib"
                                done
                                lib=''

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
                echo "Cleaning LIBS_ARRAY"
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

# Function that runs pb and will automatically open the log output if a test fails. If more than one
# test fails, you will be asked which you want to open until you give a quit command.
run()
{
        # TODO: write checks for compiler errors, only execute opening step if a valid file is pulled
        lines=()
        CUR_TIME=$(date +'%Y-%m-%d %T')

        if [ -z "$1" ]
        then
                #PB_TEST=''
                echo "ERROR: Please supply an argument flag.  Type 'run -h' for usage."
                return 1
        else
                case "$1" in
                        -h|--help)
                                echo "*** run command: helper wrapper for running pb run ***"
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

        OPEN_LOG_FILE="false"
        TEST_CASES=()
        TEST_CASE=""
        BUILD_FAILED="false"
        # 2>&1 grabs all stdout and stderr output
        $COMMAND 2>&1 | {
                while IFS= read -r line
                do
                        IS_FAIL_LINE="false"
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
                                        IS_FAIL_LINE="true"
                                        TEST_CASE=''
                                        OPEN_LOG_FILE="true"
                                        TEST_CASE="${line##* }"
                                        TEST_CASE=${TEST_CASE%^*}
                                        TEST_CASES+=("$TEST_CASE")

                                fi
                                if [[ "$word" =~ "ERROR" ]]
                                then
                                        BUILD_FAILED="true"
                                fi

                        done

                        # I can't figure out how to print the numbers as they change... th bash
                        # scanner can't do it :(
                        if [ "$IS_FAIL_LINE" == "true" ]
                        then
                                # Make the fail testcase lines pretty and red like pb normally makes
                                # them!
                                printf "\e[31m%s\n\e[0m" "$line"
                        else
                                printf "%s\n" "$line"
                        fi

                done
        }
        echo "Finished"

        if [[ "$BUILD_FAILED" = true ]]
        then
                BUILD_FAILED=''
                return 0
        fi
        BUILD_FAILED=''

        if [[ "$OPEN_LOG_FILE" = true ]]
        then
                # If only one result, open that file, otherwise present the user with an option
                if [ ${#TEST_CASES[@]} == "1" ]
                then
                        #LOG_FILE="$PLAN/${TEST_CASE}__${TASK}__failed.stdout"
                        TEST_CASE="${TEST_CASES[0]}"
                        FIND_FILE_CMD="find $PLAN -name *.stdout | grep --color=never -e $TEST_CASE"
                        LOG_FILE="$(eval $FIND_FILE_CMD)"
                        echo "Opening log file: $LOG_FILE"
                        vi $LOG_FILE
                else
                        # Allow the user to open log files until inputing 'quit' command
                        while true
                        do
                                echo "${#TEST_CASES[@]} test cases failed:"
                                counter=1
                                COLOR_CODE=31
                                # Print failed test cases list, color code them for ease of eyes
                                for fl in "${TEST_CASES[@]}"; do
                                        echo -e "\e[${COLOR_CODE}m[$counter] $fl"
                                        (( counter++ ))
                                        (( COLOR_CODE++ ))
                                        if [[ $COLOR_CODE -gt 36 ]]
                                        then
                                                COLOR_CODE=31
                                        fi
                                done
                                COLOR_CODE=''
                                echo -en "\e[0mType the index of the testcase you want to open the stdout file for (or 'q' to exit) and press [ENTER]: "
                                read choice

                                if [ "$choice" == "q" ]
                                then
                                        echo "Quit command recieved, quitting."
                                        return 0
                                fi

                                # Check to see if input is valid.  First check that it's a number
                                if [[ -n ${choice//[0-9]/} ]]
                                then
                                        echo "Invalid input, try again using only numbers or 'q' to quit"
                                        continue
                                else
                                        # Now check that the input is in the valid range of choices
                                        if [ $choice -lt 1 ] || [ $choice -gt ${#TEST_CASES[@]} ]
                                        then
                                                echo "Invalid input, input out of range"
                                                continue
                                        fi
                                fi
                                # Convert to array index and assign
                                (( choice-- ))

                                TEST_CASE="${TEST_CASES[choice]}"
                                FIND_FILE_CMD="find $PLAN -name *.stdout | grep --color=never -e $TEST_CASE"
                                LOG_FILE="$(eval $FIND_FILE_CMD)"

                                # Rather than opening a new vi file, throw error message if file couldn't be found
                                if [ -z LOG_FILE ]
                                then
                                        echo "ERROR: Could not find log file for $TEST_CASE, plan directory may be incorrect"
                                        continue
                                fi
                                #LOG_FILE="$PLAN/${TEST_CASE}__${TASK}__failed.stdout"
                                echo "Opening log file: $LOG_FILE"
                                vi $LOG_FILE
                        done
                fi
        fi

        TEST_CASE=''
        LOG_FILE=''
        FIND_FILE_CMD=''
}

# Asuuming you've mounted a tlog directory in your VM, this function allows you to auto-navigate to
# that folder, or the proper jenkins/job/run sub dir if you provide the job URL.
# Usage:
# - tlog http://repjenkins.dev.purestorage.com:8080/job/nearsync_cli-test3/77/
# - tlog
#
# tlog mounting documentation https://wiki.purestorage.com/display/psw/Mounting+tlogs
tlog()
{
        TLOG_DIR="/home/mkali/work/logs/tlogs"
        DEST_DIR=''
        T_JENKINS=''
        T_JOB=''
        T_RUN=''
        JEN=''
        SLASHES=''
        found_job=''

        if [ -z "$1" ]
        then
                DEST_DIR="$TLOG_DIR"
        else

                IFS='/' read -ra SLASHES <<< "$1"

                # Scan the url and grab the information we want
                found_job="false"
                for sub in "${SLASHES[@]}"; do
                        if [[ $sub == *"jenkins"* ]]
                        then
                                T_JENKINS="$sub"
                        fi
                        if [[ -n $T_JOB ]]
                        then
                                T_RUN="$sub"
                        fi

                        if [[ $found_job == "true" ]]
                        then
                                T_JOB="$sub"
                        fi

                        if [[ $sub == "job" ]]
                        then
                                found_job="true"
                        else
                                found_job="false"
                        fi

                done
                sub=''
                # fix the jenkins line
                IFS="." read -ra JEN <<< "$T_JENKINS"
                T_JENKINS="${JEN[0]}"
                IFS=":" read -ra JEN <<< "$T_JENKINS"
                T_JENKINS="${JEN[0]}"

                if [ -z $T_JENKINS ] || [ -z $T_JOB ] || [ -z $T_RUN ]
                then
                        echo "ERROR: input URL is invalid"
                        return 1
                fi

                #echo "T_JENKINS = $T_JENKINS"
                #echo "T_JOB = $T_JOB"
                #echo "T_RUN = $T_RUN"

                DEST_DIR="$TLOG_DIR/$T_JENKINS/jobs/$T_JOB/$T_RUN"
        fi
        echo "cd $DEST_DIR"

        cd $DEST_DIR

        TLOG_DIR=''
        DEST_DIR=''
        T_JENKINS=''
        T_JOB=''
        T_RUN=''
        JEN=''
        SLASHES=''
        found_job=''
}

# NOTE: Somewhat depreciated, no longer upkept
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
        REMOTE_FILE_IS_GZ='false'

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
                                        REMOTE_FILE_IS_GZ='true'
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

        if [[ $REMOTE_TARGET_FILE == *"gz" ]];
        then
                #echo "It's a gunzip file"
                REMOTE_FILE_IS_GZ='true'
        else
                #echo "it's a regular file"
                REMOTE_FILE_IS_GZ='false'
        fi


        if [ "$REMOTE_FILE_IS_GZ" = true ]
        then
                COMMAND="ssh root@$REMOTE_TARGET$REMOTE_CONTROLLER 'zcat $REMOTE_LOG_DIR/$REMOTE_TARGET_FILE' | vi - -c ':set colorcolumn='"
        else
                COMMAND="ssh root@$REMOTE_TARGET$REMOTE_CONTROLLER 'cat $REMOTE_LOG_DIR/$REMOTE_TARGET_FILE' | vi - -c ':set colorcolumn='"
        fi
        #ssh root@d107-3-ct0 'zcat /var/log/purity/platform.log.gz' | vi -

        echo "Calling: $COMMAND"

        eval $COMMAND

        COMMAND=''
        REMOTE_CONTROLLER=''
        REMOTE_LOG_DIR=''
        REMOTE_TARGET_FILE=''
        REMOTE_FILE_IS_GZ=''
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
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-t, --testbed             set the target testbed array"
                                echo "-s, --setup               setup/update the testbed on target array"
                                echo "-r, --run                 run regularly without setup"
                                echo "-rf, --refresh            run ssd reset on the testbed"
                                echo "-hmo, --health            run hmo healthchecks on the testbed"
                                echo "--no-io                   run regularly without IO"
                                echo "-db, --debug              run in debug mode w/ pdb"
                                return 0
                                ;;
                        -t|--testbed)
                                # TODO Implement this yo
                                if [ -z "$2" ]
                                then
                                        if [ -z "$TESTBED" ]
                                        then
                                                echo "Please provide an array to test on."
                                                return 1
                                        fi
                                        echo "Current target array is $TESTBED"
                                        return 0
                                fi
                                TESTBED="$2"
                                TESTBED=${TESTBED#"lp-"}
                                TESTBED="lp-$TESTBED"

                                echo "Setting target testbed array to $TESTBED"
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
                        -hmo|--health)
                                COMMAND_STR="$SETUP_TB_FILE_LOC --testbed $TESTBED --skip-update"
                                requires_file=false
                                ;;
                        --no-io)i
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
                echo "ERROR: Please set the target testbed using 'ptest -t [testbed]'";
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
