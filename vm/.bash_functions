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
        GLOBAL_ARR+=("DEBUG_BUILD_FLAG: [$DEBUG_BUILD_FLAG] used for update_libs")

        # TARGET_ARRAY # for update_libs
        # REMOTE_TARGET # for rlog
        # PB_TEST # for run
        # TESTBED # For ptest
        # DEBUG_BUILD_FLAG # for update_libs

        for var in "${GLOBAL_ARR[@]}"
        do
                echo "- $var"
        done

        var=''
        GLOBAL_ARR=''
}

tester()
{
        echo "Tester function: start"

        test_line="2021-10-15 16:43:57,699 ==  FAILED  ==  ha.lawn_svc.stem_check_location_health.1                           ...    task-25d18788858e9d40 --    86856 ms"
        test_line="2021-10-28 20:19:42,353 ==  FAILED  ==      6963 ms -- task-58d19a611f2bf556  -- worker-6056e4233103fcf3 -- ha.stem_check.hwman_check"
        echo "$test_line"
        test_ar=( $test_line )
        echo ${test_ar[5]}
        echo ${test_ar[-1]}
        test_line=''
        test_ar=''
        echo "Tester function: end"
}

#useful for debugging and testing
testF()
{
        if echo "vmmkali" | grep -q "vm"; then
            echo "matched";
        else
            echo "no match";
        fi
}

get_docker_devel_id()
{
        # DOCKER_DEVEL_ID will be set by this
        # This function checks docker devel and will grab the id.
        DOCKER_DEVEL_ID=''
        COMMAND='docker ps'
        # 1 is stdout, 2 is stderr.  $COMMAND 2>&1 means we run the cmd and redirect fp stderr to
        # stdout.  THe | then redirects this output to a subshell defined by the {}.  Because we
        # can't assign global variable upwards from subshell to this one, we have to capture the
        # result via echo and by wrapping the whole thing in an eval $()
        DOCKER_DEVEL_ID=$($COMMAND 2>&1 | {
                while IFS= read -r line
                do
                        IS_FAIL_LINE="false"
                        #echo "line - $line"
                        FIRST=''
                        for word in $line
                        do
                                #echo "Word $word"
                                if [ -z "$FIRST" ]
                                then
                                        FIRST="$word"
                                        #echo "Setting first to $FIRST"
                                fi
                                if [[ "$word" =~ "develop" ]]
                                then
                                        #echo "Found! first is $FIRST"
                                        DOCKER_DEVEL_ID="$FIRST"
                                        #echo "docker id = $DOCKER_DEVEL_ID"
                                fi
                        done
                        #echo " --- "
                        #nnecho "docker id = $DOCKER_DEVEL_ID"
                done
                echo "$DOCKER_DEVEL_ID"
        })

        COMMAND=''
}

gdiff()
{
        TARGET_BRANCH=''
        if [ -z "$1" ]
        then
                TARGET_BRANCH=@{u}
        else
                TARGET_BRANCH="$1"
        fi



        echo "Comparing local branch to $TARGET_BRANCH.\nIf you are rebasing, there should be no lines <\n"
        echo "Important: < are commits in $TARGET_BRANCH that aren't in HEAD, > are the opposite."
        echo "Calling: diff <(git log --oneline HEAD..$TARGET_BRANCH | cut -d ' ' -f 2-) <(git log --oneline $TARGET_BRANCH..HEAD | cut -d ' ' -f 2-)"

        diff <(git log --oneline HEAD..$TARGET_BRANCH | cut -d ' ' -f 2-) <(git log --oneline $TARGET_BRANCH..HEAD | cut -d ' ' -f 2-)

        TARGET_BRANCH=''
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

# util for updating random files
update_rfiles()
{
        if [ -z "$1" ]
        then
                echo "Error: please supply an array name"
                return 0
        fi

        echo "Sending random (plz edit the scrip to change) files to $1"

        CMD_ARR=()
        CMD_ARR+=("scp tools/pure/health_check/oxygen/oxygen_ndu_physical_check.py root@$1:/opt/Purity/bin/oxygen_ndu_physical_check.py")
        CMD_ARR+=("scp tools/pure/health_check/oxygen/oxygen_ndu_physical_check.py root@$1:/usr/lib/python3/dist-packages/pure/health_check/oxygen/oxygen_ndu_physical_check.py")
        CMD_ARR+=("scp tools/pure/health_check/oxygen/oxygen_ndu_health_check.py root@$1:/opt/Purity/bin/oxygen_ndu_health_check.py")
        CMD_ARR+=("scp tools/pure/health_check/oxygen/oxygen_ndu_health_check.py root@$1:/usr/lib/python3/dist-packages/pure/health_check/oxygen/oxygen_ndu_health_check.py")
        CMD_ARR+=("scp tools/pure/ndu_tools/chassis_pre_ndu_setup root@$1:/opt/Purity/bin/chassis_pre_ndu_setup")
        CMD_ARR+=("scp tools/pure/ndu_tools/chassis_pre_ndu_setup root@$1:/usr/lib/python3/dist-packages/pure/ndu_tools/chassis_pre_ndu_setup")

        CMD_ARR+=("scp tools/pure/ndu_tools/remote_nvram_switch root@$1:/opt/Purity/bin/remote_nvram_switch")
        CMD_ARR+=("scp tools/pure/ndu_tools/remote_nvram_switch root@$1:/usr/lib/python3/dist-packages/pure/ndu_tools/remote_nvram_switch")
        for var in "${CMD_ARR[@]}"
        do
                echo "Sending $var"
                $var
        done

        var=''
        CMD_ARR=''
}

# Prototype utility for updating an alert probe to a target array
update_alert_n()
{

        CONTROLLER_0=''
        CONTROLLER_1=''
        TARGET_ALERT=''
        if [ -z "$1" ]
        then
                echo "Error: Please supply an argument flag with function call. (update_alert -h for help)"
                return 0
        else
                case "$1" in
                        -h|--help)
                                echo "*** update_alert command: helper for sending alert probe changes to a target array ***"
                                echo " "
                                echo "update_alert [option] [args]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-t, --testbed             set the target testbed array"
                                echo "-u, --update              send [ARG] glert files.  A target probe must be specified as an argument (e.g. drive_probe)"
                                echo " ******* "
                                echo " "
                                return 0
                                ;;
                        -t|--testbed)
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
                        -u|--update)
                                if [ -z "$2" ]
                                then
                                        echo "Please provide the alert to update. (e.g. drive_probe)"
                                        return 1
                                fi
                                TARGET_ALERT="$2"
                                echo "Sending alert $TARGET_ALERT"
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Use -h for options"
                                return 1
                                ;;
                esac
        fi

        if [ -z "TARGET_ARRAY" ]
        then
                echo "Error: Target array must be set.  Run update_alert -t [array]."
                return 1
        fi

        CONTROLLER_0="$TARGET_ARRAY-ct0"
        CONTROLLER_1="$TARGET_ARRAY-ct1"

        TARGET_FILE_ARRAY=()
        TARGET_FILE_ARRAY+=("/home/mkali/work/purity/tools/pure/alert/monitor/$TARGET_ALERT.py")
        TARGET_FILE_ARRAY+=("home/mkali/work/purity/tools/pure/alert/monitor/test/$TARGET_ALERT_test.py")
        TARGET_FILE_ARRAY+=("home/mkali/work/purity/tools/pure/alert/monitor/monitor.py")

        TARGET_FILE_DEST_ARRAY=()
        TARGET_FILE_DEST_ARRAY+=("/usr/lib/python3/dist-packages/pure/alert/monitor/$TARGET_ALERT.py")
        TARGET_FILE_DEST_ARRAY+=("/usr/lib/python3/dist-packages/pure/alert/monitor/test/$TARGET_ALERT_test.py")
        TARGET_FILE_DEST_ARRAY+=("/usr/lib/python3/dist-packages/pure/alert/monitor/monitor.py")

        CT_ARRAY=( "$TARGET_ARRAY-ct0" "$TARGET_ARRAY-ct1" )
        CMD_ARRAY=()
        echo "Building cmds"
        for ct in "${TARGET_CONTROLLERS[@]}"
        do
                for ((idx=0; idx<${#TARGET_FILE_ARRAY[@]}; ++idx));
                do
                        CUR_CMD="scp ${TARGET_FILE_ARRAY[idx]} root@$ct:${TARGET_FILE_DEST_ARRAY[idx]}"
                        echo "Adding $CUR_CMD"
                        CMD_ARRAY+=("$CUR_CMD")
                done
        done
        CUR_CMD=''

        echo "Running commands"

        CONTROLLER_0=''
        CONTROLLER_1=''
        CT_ARRAY=''
        CMD_ARRAY=''
        TARGET_FILE_ARRAY=''
        TARGET_FILE_DEST_ARRAY=''
        TARGET_ALERT=''

}

# Prototype utility for compiling and sending middleware.java updates to a target array
update_middleware()
{

        COMPILE_LIB=''
        SCP_LIB=''
        CONTROLLER_0=''
        CONTROLLER_1=''
        #./middleware/sbin/build_middleware.sh
        #scp middleware/target/*.jar root@<testbed>-<controller>:/opt/Purity/middleware/
        if [ -z "$1" ]
        then
                echo "Error: Please supply an argument flag with function call. (update_middleware -h for help)"
                return 0
        else
                case "$1" in
                        -h|--help)
                                echo "*** update_middleware command: helper for compiling changes to middleware and sending them to a target array ***"
                                echo " "
                                echo "update_middleware [option] [args]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-t, --testbed             set the target testbed array"
                                echo "-u, --update              compile and send middleware binaries to the target"
                                echo " ******* "
                                echo " "
                                return 0
                                ;;
                        -t|--testbed)
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
                        -u|--update)
                                COMPILE_LIB="/home/mkali/work/purity/middleware/sbin/build_middleware.sh"
                                CONTROLLER_0="$TARGET_ARRAY-ct0"
                                CONTROLLER_1="$TARGET_ARRAY-ct1"
                                SCP_LIB_0="scp /home/mkali/work/purity/middleware/target/*.jar root@$CONTROLLER_0:/opt/Purity/middleware/"
                                SCP_LIB_1="scp /home/mkali/work/purity/middleware/target/*.jar root@$CONTROLLER_1:/opt/Purity/middleware/"
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Use -h for options"
                                return 1
                                ;;
                esac
        fi

        if [ -z "$COMPILE_LIB" ]
        then
                return 0
        fi

        if [ -z "TARGET_ARRAY" ]
        then
                echo "Error: Target array must be set.  Run update_middleware -t [array]."
                return 1
        fi

        CUR_TIME=$(date +'%Y-%m-%d %T')
        echo "Beginning middleware library update at $CUR_TIME"
        echo "Running: $COMPILE_LIB"
        $COMPILE_LIB
        echo "Running: $SCP_LIB_0"
        $SCP_LIB_0
        echo "Running: $SCP_LIB_1"
        $SCP_LIB_1
        echo "Done."
        return 0
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
        ALL_BIN_ARRAY=( "foed" "platform_framework" )

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
                                echo "-b, --specific-binary     update specific binaries.  (ex: 'foed platform_framework')"
                                echo "-db, --debug              set debug build.  (ex: '-db 0' to unset or '-db 1' to set)"
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
                                echo "Binaries available to compile:"
                                for binary in "${ALL_BIN_ARRAY[@]}"
                                do
                                        echo "  -- $binary"
                                done
                                binary=''

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
                                LIB_CMD='true'
                                BIN_CMD='false'
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
                                        LIB_CMD='true'
                                        BIN_CMD='false'
                                fi
                                ;;
                        -b|--specific-binary)

                                if [ -z "$2" ]
                                then
                                        echo "Please provide a specific binary to update."
                                        return 1
                                else
                                        BIN_ARRAY=()
                                        # iterate through all arguments after the first
                                        for binary in "${@:2}"
                                        do
                                                # Verify binary is a valid choice
                                                if [[ " ${ALL_BIN_ARRAY[@]} " =~ " ${binary} " ]]
                                                then
                                                        echo "updating $binary"
                                                        BIN_ARRAY+=("$binary")
                                                else
                                                        echo "NOTE: $binary is not a valid library name"
                                                fi
                                        done
                                        binary=''
                                        LIB_CMD='false'
                                        BIN_CMD='true'
                                fi
                                ;;
                        -db|--debug)
                                if [ -z "$2" ]
                                then
                                        if [ -z "$DEBUG_BUILD_FLAG" ]
                                        then
                                                echo "Debug build status is currently 'false'"
                                        else
                                                echo "Debug build status is currently '$DEBUG_BUILD_FLAG'"
                                        fi
                                        return 0
                                else
                                        if [ $2 == 0 ]
                                        then
                                                echo "Debug build disabled"
                                                DEBUG_BUILD_FLAG="false"
                                        elif [ $2 == 1 ]
                                        then
                                                echo "Debug build enabled"
                                                DEBUG_BUILD_FLAG="true"
                                        else
                                                echo "Invalid input (use 0 or 1)"
                                                return 1
                                        fi
                                fi
                                return 0
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Pass -h for options."
                                return 1
                                ;;
                esac
        fi

        echo "Starting at $CUR_TIME"

        # TODO: make this optional
        SEND_TO_ARRAY="true"

        if [[ $LIB_CMD == "true" ]]
        then
                make_libs_docker

                if [[ $SEND_TO_ARRAY == "true" ]]
                then
                        send_libs
                fi
        fi
        if [[ $BIN_CMD == "true" ]]
        then
                make_bins_docker

                if [[ $SEND_TO_ARRAY == "true" ]]
                then
                        send_bins
                fi
        fi

        # Clean all variables
        LIBS_ARRAY=''
        ALL_LIBS_ARRAY=''
        BIN_ARRAY=''
        ALL_BIN_ARRAY=''
        BIN_CMD=''
        LIB_CMD=''
        #TARGET_ARRAY=''
}

make_libs_docker()
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

        get_docker_devel_id

        if [ -z "$DOCKER_DEVEL_ID" ]
        then
                echo "No docker devel env created yet, plz create it and try again"
                echo "Hint: Run 'pb devel base' and './ppremake'"
                exit 1
        fi

        DOCKER_LIB_BUILD_DIR="/build/src/bld_linux/purity"
        DOCKER_LIB_DEST_DIR="/build/src/bld_linux/purity/lib"
        LOCAL_LIB_DEST_DIR="/home/mkali/work/bld_linux/purity/lib"

        LIB_TYPE="Release"
        if [[ $DEBUG_BUILD_FLAG == "true" ]]
        then
                LIB_TYPE="Debug"
        fi

        for IDX in "${!LIBS_ARRAY[@]}"
        do
                CUR_LIB="${LIBS_ARRAY[$IDX]}"
                TARGET_LIB="$CUR_LIB-$LIB_TYPE"
                echo "Compiling: $TARGET_LIB"
                CMD="ninja -j 160 -C $DOCKER_LIB_BUILD_DIR $TARGET_LIB"
                DOCKER_CMD="docker exec -it $DOCKER_DEVEL_ID sh -c \"$CMD\""

                echo " - $DOCKER_CMD"
                # Use eval b/c of inner quotations
                eval $DOCKER_CMD

                # copy to normal ouptut file
                OUTPUT_LIB="lib$CUR_LIB.so"
                CPY_CMD="docker cp $DOCKER_DEVEL_ID:$DOCKER_LIB_DEST_DIR/$OUTPUT_LIB $LOCAL_LIB_DEST_DIR/"
                echo " - $CPY_CMD"
                $CPY_CMD

                if [[ $DEBUG_BUILD_FLAG == "true" ]]
                then
                        # IF debug flag is set, we need to append 'D' to the library name
                        LIBS_ARRAY[$IDX]="$CUR_LIB""D"
                fi
        done

        echo "Done compiling all libraries"

        if [[ $CLEAN == "true" ]]
        then
                echo "Cleaning LIBS_ARRAY"
                LIBS_ARRAY=''
        fi
        LIB_TYPE=''
        CUR_LIB=''
        DOCKER_LIB_BUILD_DIR=''
        DOCKER_LIB_DEST_DIR=''
        LOCAL_LIB_DEST_DIR=''
        TARGET_LIB=''
        OUTPUT_LIB=''
        CMD=''
        CPY_CMD=''
        CLEAN=''
 # ****
}

# DEPRECIATED, this method builds locally.  Until local build dependencies are resolved, we can't use
# this method anymore
make_libs_local()
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

        LIB_TYPE="Release"
        if [[ $DEBUG_BUILD_FLAG == "true" ]]
        then
                LIB_TYPE="Debug"
        fi

        for IDX in "${!LIBS_ARRAY[@]}"
        do
                CUR_LIB="${LIBS_ARRAY[$IDX]}"
                TARGET_LIB="$CUR_LIB-$LIB_TYPE"
                echo "Compiling: $TARGET_LIB"
                CMD="ninja -j 10 -C $LIB_OUTPUT_DIR $TARGET_LIB"

                echo " - $CMD"
                $CMD
                if [[ $DEBUG_BUILD_FLAG == "true" ]]
                then
                        # IF debug flag is set, we need to append 'D' to the library name
                        LIBS_ARRAY[$IDX]="$CUR_LIB""D"
                fi
        done

        echo "Done compiling all libraries"

        if [[ $CLEAN == "true" ]]
        then
                echo "Cleaning LIBS_ARRAY"
                LIBS_ARRAY=''
        fi
        LIB_TYPE=''
        CUR_LIB=''
        TARGET_LIB=''
        CMD=''
        CLEAN=''
}
make_bins_docker()
{
        # To change make optimization flags goto purity base directory and run
        # ppremake.sh with the desired flags.
        # Ex: ./ppremake.sh --cc=gcc --optimize=3
        # TODO: make this into it's own separate cmd option?
        if [ -z "$BIN_ARRAY" ]
        then
                echo "No binary array provided, exiting"
                return
        fi

        get_docker_devel_id

        if [ -z "$DOCKER_DEVEL_ID" ]
        then
                echo "No docker devel env created yet, plz create it and try again"
                echo "Hint: Run 'pb devel base' and './ppremake'"
                exit 1
        fi

        DOCKER_BIN_BUILD_DIR="/build/src/bld_linux/purity"
        DOCKER_BIN_DEST_DIR="/build/src/bld_linux/purity/bin"
        LOCAL_BIN_DEST_DIR="/home/mkali/work/bld_linux/purity/bin"

        BIN_TYPE="Release"
        if [[ $DEBUG_BUILD_FLAG == "true" ]]
        then
                BIN_TYPE="Debug"
        fi

        for IDX in "${!BIN_ARRAY[@]}"
        do
                CUR_BIN="${BIN_ARRAY[$IDX]}"
                TARGET_BIN="$CUR_BIN-$BIN_TYPE"
                echo "Compiling: $TARGET_BIN"
                CMD="ninja -j 160 -C $DOCKER_BIN_BUILD_DIR $TARGET_BIN"
                DOCKER_CMD="docker exec -it $DOCKER_DEVEL_ID sh -c \"$CMD\""

                echo " - $DOCKER_CMD"
                # Use eval b/c of inner quotations
                eval $DOCKER_CMD

                # copy to normal ouptut file
                OUTPUT_BIN="$CUR_BIN"
                CPY_CMD="docker cp $DOCKER_DEVEL_ID:$DOCKER_BIN_DEST_DIR/$OUTPUT_BIN $LOCAL_BIN_DEST_DIR/"
                echo " - $CPY_CMD"
                $CPY_CMD

        done

        echo "Done compiling all libraries"

        if [[ $CLEAN == "true" ]]
        then
                echo "Cleaning LIBS_ARRAY"
                BIN_ARRAY=''
        fi
        BIN_TYPE=''
        CUR_BIN=''
        DOCKER_BIN_BUILD_DIR=''
        DOCKER_BIN_DEST_DIR=''
        LOCAL_BIN_DEST_DIR=''
        TARGET_BIN=''
        OUTPUT_BIN=''
        CMD=''
        CPY_CMD=''
        CLEAN=''
 # ****
}

make_bins()
{
        # To change make optimization flags goto purity base directory and run
        # ppremake.sh with the desired flags.
        # Ex: ./ppremake.sh --cc=gcc --optimize=3
        # TODO: make this into it's own separate cmd option?
        if [ -z "$BIN_ARRAY" ]
        then
                echo "No binary array provided, exiting"
                return
        fi

        # TODO: use DEBUG_BUILD_FLAG to enable debug binaries

        LIB_OUTPUT_DIR="/home/mkali/work/bld_linux/purity/"

        for CUR_BIN in "${BIN_ARRAY[@]}"
        do
                TARGET_BIN="$CUR_BIN-Release"
                echo "Compiling: $TARGET_BIN"
                CMD="ninja -j 10 -C $LIB_OUTPUT_DIR $TARGET_BIN"

                # echo " - $CMD"
                $CMD
        done

        echo "Done compiling all libraries"

        if [[ $CLEAN == "true" ]]
        then
                echo "Cleaning BIN_ARRAY"
                BIN_ARRAY=''
        fi
        CUR_BIN=''
        TARGET_BIN=''
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
        TARGET_ARRAY_IS_VM='false'
        if [ -z "$TARGET_ARRAY" ]
        then
                echo "ERROR: TARGET_ARRAY variable must be set"
                return 1
        else
                if echo "$TARGET_ARRAY" | grep -q "vm"; then
                        TARGET_ARRAY_IS_VM='true'
                fi
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
                if [[ $TARGET_ARRAY_IS_VM == "true" ]]
                then
                        echo "Sending '$TARGET_FILE' to '$TARGET_ARRAY'"
                        CMD="scp $SOURCE_LIB_DIR/$TARGET_FILE root@$TARGET_ARRAY:$TARGET_LIB_DIR"
                        echo "Calling: $CMD"
                        $CMD
                else
                        echo "Sending '$TARGET_FILE' to '$CONTROLLER_0' and '$CONTROLLER_1'"
                        CMD_1="scp $SOURCE_LIB_DIR/$TARGET_FILE root@$CONTROLLER_0:$TARGET_LIB_DIR"
                        CMD_2="scp $SOURCE_LIB_DIR/$TARGET_FILE root@$CONTROLLER_1:$TARGET_LIB_DIR"

                        echo "Calling: $CMD_1"
                        echo "Calling: $CMD_2"
                        $CMD_1
                        $CMD_2
                fi
        done

        echo "Done."

        if [[ "$CLEAN" == "true" ]]
        then
                LIBS_ARRAY=''
        fi
        CLEAN=''
        CUR_LIB=''
        TARGET_FILE=''
        TARGET_ARRAY_IS_VM=''
        #TARGET_ARRAY=''
        CONTROLLER_0=''
        CONTROLLER_1=''
}

send_bins()
{
        if [ -z "$TARGET_ARRAY" ]
        then
                echo "ERROR: TARGET_ARRAY variable must be set"
                return 1
        fi

        if [ -z "$BIN_ARRAY" ]
        then
                echo "No binary array provided, exiting"
                CLEAN="true"
                return
        fi
        #TARGET_ARRAY="jm69-24"

        TARGET_BIN_DIR="/opt/Purity/bin"
        SOURCE_BIN_DIR="/home/mkali/work/bld_linux/purity/bin"

        # Remove lp- if it was input
        TARGET_ARRAY=${TARGET_ARRAY#"lp-"}

        CONTROLLER_0="$TARGET_ARRAY-ct0"
        CONTROLLER_1="$TARGET_ARRAY-ct1"

        for CUR_BIN in "${BIN_ARRAY[@]}"
        do
                TARGET_FILE="$CUR_BIN"
                echo "Sending '$TARGET_FILE' to '$CONTROLLER_0' and '$CONTROLLER_1'"
                CMD_1="scp $SOURCE_BIN_DIR/$TARGET_FILE root@$CONTROLLER_0:$TARGET_BIN_DIR"
                CMD_2="scp $SOURCE_BIN_DIR/$TARGET_FILE root@$CONTROLLER_1:$TARGET_BIN_DIR"

                echo "Calling: $CMD_1"
                echo "Calling: $CMD_2"
                $CMD_1
                $CMD_2
        done

        echo "Done."

        if [[ "$CLEAN" == "true" ]]
        then
                BIN_ARRAY=''
        fi
        CLEAN=''
        CUR_BIN=''
        TARGET_FILE=''
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
                                echo "-a, --all                 run all runtests normally"
                                echo "-r, --run                 run pb build command normally"
                                echo "-o, --open                open failed test stdout files if any"
                                echo "-t, --test [arg]          display current PB_TEST value or set if arg input"
                                echo " ******* "
                                return 0
                                ;;
                        -a|--all)
                                COMMAND="pb run runtests"
                                echo "Running all unit tests normally"
                                $COMMAND
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
                                        #echo "Cur line = $line"
                                        LINE_AR=( $line )
                                        #TEST_CASE=${LINE_AR[5]}
                                        TEST_CASE=${LINE_AR[-1]}
                                        #TEST_CASE="${line##* }"
                                        #TEST_CASE=${TEST_CASE%^*}
                                        TEST_CASES+=("$TEST_CASE")
                                        LINE_AR=''
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
                        FILE_SUFF="runner.out"
                        TEST_CASE="${TEST_CASES[0]}"
                        FIND_FILE_CMD="find $PLAN -name *$FILE_SUFF | grep --color=never -e $TEST_CASE"
                        LOG_FILE="$(eval $FIND_FILE_CMD)"
                        echo "finding log file from: find $PLAN -name *$FILE_SUFF | grep -e $TEST_CASE"
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
                                #FIND_FILE_CMD="find $PLAN -name *.stdout | grep --color=never -e $TEST_CASE"
                                FIND_FILE_CMD="find $PLAN -name *$FILE_SUFF | grep --color=never -e $TEST_CASE"
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

update_alert()
{


        if [ -z "$1" ]
        then
                echo "ERROR: Please supply an argument flag.  Type 'update_alert -h' for usage."
                return 1
        else
                case "$1" in
                        -h|--help)
                                echo "*** update_alert command: helper for updating an alert probe on a specified ssh target ***"
                                echo " "
                                echo "update_alert [option(s)] [args]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-t, --target              show current remote target or [arg] set one"
                                echo "-u, --update              updates the target array with the supplied [arg] alert probe"
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
                        -u|--update)
                                if [ -z "$REMOTE_TARGET" ]
                                then
                                        echo "Please set a target array first. Use 'update_alert -t [array]'"
                                        return 1
                                fi

                                if [ -z "$2" ]
                                then
                                        echo "Please provide a target alert. EX: cache_location"
                                        return 1
                                fi
                                PROBE="$2"
                                echo "Updating $PROBE"
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Pass -h for options."
                                return 1
                                ;;
                esac
        fi

        FILE_1="${PROBE}_probe.py"
        FILE_2="${PROBE}_probe_data.py"
        FILE_3="monitor_test.py"
        FILE_4="alert.py"

        PURITY_DIR="/home/mkali/work/purity"
        PATH_1="$(eval 'find $PURITY_DIR -name $FILE_1')"
        PATH_2="$(eval 'find $PURITY_DIR -name $FILE_2')"
        PATH_3="$(eval 'find $PURITY_DIR -name $FILE_3')"
        PATH_4="$PURITY_DIR/tools/pure/alert/alert.py"

        CONTROLLER_0="$REMOTE_TARGET-ct0"
        CONTROLLER_1="$REMOTE_TARGET-ct1"

        CUR_CONTROLLER="$CONTROLLER_0"
        CMD_1="scp $PATH_1 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/monitor/$FILE_1"
        CMD_2="scp $PATH_2 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/monitor/test/data/$FILE_2"
        CMD_3="scp $PATH_3 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/test/$FILE_3"
        CMD_4="scp $PATH_4 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/$FILE_4"

        echo "Sending files to $CUR_CONTROLLER..."
        echo "Calling: $CMD_1"
        $CMD_1
        echo "Calling: $CMD_2"
        $CMD_2
        echo "Calling: $CMD_3"
        $CMD_3
        echo "Calling: $CMD_4"
        $CMD_4

        CUR_CONTROLLER="$CONTROLLER_1"
        CMD_1="scp $PATH_1 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/monitor/$FILE_1"
        CMD_2="scp $PATH_2 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/monitor/test/data/$FILE_2"
        CMD_3="scp $PATH_3 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/test/$FILE_3"
        CMD_4="scp $PATH_4 root@$CUR_CONTROLLER:/usr/lib/python2.7/dist-packages/pure/alert/$FILE_4"

        echo "Sending files to $CUR_CONTROLLER..."
        echo "Calling: $CMD_1"
        $CMD_1
        echo "Calling: $CMD_2"
        $CMD_2
        echo "Calling: $CMD_3"
        $CMD_3
        echo "Calling: $CMD_4"
        $CMD_4

        FILE_1=''
        FILE_2=''
        FILE_3=''
        PATH_1=''
        PATH_2=''
        PATH_3=''
        CONTROLLER_0=''
        CONTROLLER_1=''
        CUR_CONTROLLER=''
        CMD_1=''
        CMD_2=''
        CMD_3=''
        CMD_4=''

        return 0
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

        if [ \( "$REMOTE_CONTROLLER" == "v" \) -o \( "$REMOTE_CONTROLLER" == "vm" \) ]
        then
                REMOTE_CONTROLLER="virtual"
        fi

        # Bark about bad input
        if [ \( "$REMOTE_CONTROLLER" != "-ct0" \) -a \( "$REMOTE_CONTROLLER" != "-ct1" \) -a \( "$REMOTE_CONTROLLER" != "virtual" \) ]
        then
                echo "ERROR: [ $REMOTE_CONTROLLER ] is a bad input for controller target.  Specify '0, ct0' or '1, ct1' for controls 0 and 1 respectively, or 'v' 'vm' for a virtual target"
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

        if [ "$REMOTE_CONTROLLER" == "virtual" ]
        then
                REMOTE_CONTROLLER=""
        fi

        if [ "$REMOTE_FILE_IS_GZ" = true ]
        then
                #COMMAND="ssh root@$REMOTE_TARGET$REMOTE_CONTROLLER 'zcat $REMOTE_LOG_DIR/$REMOTE_TARGET_FILE' | grep -v flut | vi - -c ':set colorcolumn='"
                COMMAND="ssh root@$REMOTE_TARGET$REMOTE_CONTROLLER 'zcat $REMOTE_LOG_DIR/$REMOTE_TARGET_FILE' | vi - -c ':set colorcolumn='"
        else
                #COMMAND="ssh root@$REMOTE_TARGET$REMOTE_CONTROLLER 'cat $REMOTE_LOG_DIR/$REMOTE_TARGET_FILE' | grep -v flut | vi - -c ':set colorcolumn='"
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
        FILE_EXTENSIONS="h,cpp,py,java"
        SPECIFIC_EXCLUSIONS=( "populate.py" "diagnostics_versions.py" )
        EXCLUSION_STR=''
        for var in "${SPECIFIC_EXCLUSIONS[@]}"
        do
                EXCLUSION_STR="--exclude=$var $EXCLUSION_STR"
        done
        var=''

        CUR_DIR=$(pwd)
        OPEN_FILE=false
        OPTION_COUNTER=0
        MULTI_OPTION_SUPPORT=true
        # Multiple options are enabled on a cmd basis.  This means, only a single command can exist
        # per option set, but multiple options FOR that command can exist, and should be formatted
        # with option flags.
        COMMAND_OPTION=''
        COMMAND_ARGS=''
        COMMAND_ARG_COUNTER=0

        # *** Option flag booleans ***
        OPTION_ARGS=''
        REMOTE_BRANCH=false

        GRAB_NEXT_OPTION_ARG=false
        GRAB_NEXT_CMD_ARG=false
        for arg in "$@"
        do
                case "$arg" in
                        -h|--help)
                                echo "*** pfind command: helper for grepping and finding ***"
                                echo " "
                                echo "pfind [option] [pattern/file]"
                                echo " "
                                echo "options:"
                                echo "-h, --help                show brief help"
                                echo "-f, --find                find a file in sub dirs"
                                echo "-o, --open                open a file if it exists in sub dirs"
                                echo "-rb, --remote-branch      specify a remote branch to open a file for"
                                echo "-g, --grep                grep for a pattern in sub dirs"
                                echo "-ga, --grep-all           grep for a pattern in all file types"
                                echo "-gl                       grep for a pattern in .log files"
                                echo "-gc                       grep for a pattern in .config files"
                                echo " ******* "
                                return 0
                                ;;
                        -f|--find)
                                COMMAND_STR="find $CUR_DIR -name"
                                ((OPTION_COUNTER++))
                                MULTI_OPTION_SUPPORT=false
                                GRAB_NEXT_CMD_ARG=true
                                ;;
                        -o|--open)
                                COMMAND_STR="find $CUR_DIR -name"
                                OPEN_FILE=true
                                ((OPTION_COUNTER++))
                                GRAB_NEXT_CMD_ARG=true
                                ;;
                        -rb|--remote-branch)
                                GRAB_NEXT_CMD_ARG=false
                                GRAB_NEXT_OPTION_ARG=true
                                ((OPTION_COUNTER++))
                                REMOTE_BRANCH=true
                                ;;
                        -g|--grep)
                                # For bash literal expansions, we need to eval echo and store the
                                # result
                                GLOB=--include=\*.{$FILE_EXTENSIONS}
                                GLOB_EXP=$(eval echo $GLOB)
                                # KALI: expand exclusions
                                COMMAND_STR="grep --color $GLOB_EXP $EXCLUSION_STR -rn $CUR_DIR -e"
                                ((OPTION_COUNTER++))
                                MULTI_OPTION_SUPPORT=false
                                GRAB_NEXT_CMD_ARG=true

                                # Clean the variables
                                GLOB=''
                                GLOB_EXP=''
                                ;;
                        -ga|--grep-all)
                                COMMAND_STR="grep --color -rn $CUR_DIR -e"
                                ((OPTION_COUNTER++))
                                MULTI_OPTION_SUPPORT=false
                                GRAB_NEXT_CMD_ARG=true
                                ;;
                        -gl)
                                # For bash literal expansions, we need to eval echo and store the
                                # result
                                FILE_EXTENSIONS+=",log"
                                GLOB=--include=\*.{$FILE_EXTENSIONS}
                                GLOB_EXP=$(eval echo $GLOB)
                                COMMAND_STR="grep --color $GLOB_EXP $EXCLUSION_STR -rn $CUR_DIR -e"
                                ((OPTION_COUNTER++))
                                MULTI_OPTION_SUPPORT=false
                                GRAB_NEXT_CMD_ARG=true

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
                                COMMAND_STR="grep --color $GLOB_EXP $EXCLUSION_STR -rn $CUR_DIR -e"
                                ((OPTION_COUNTER++))
                                MULTI_OPTION_SUPPORT=false
                                GRAB_NEXT_CMD_ARG=true

                                # Clean the variables
                                GLOB=''
                                GLOB_EXP=''
                                ;;
                        *)
                                # All other arguments will be user arguments
                                #
                                # Prioritize cmd arguments
                                if [ "$GRAB_NEXT_CMD_ARG" == true ]
                                then
                                        ((COMMAND_ARG_COUNTER++))
                                        if [ -z "$COMMAND_ARGS" ]
                                        then
                                                COMMAND_ARGS+="$arg"
                                        else
                                                COMMAND_ARGS+=" $arg"
                                        fi
                                elif [ "$GRAB_NEXT_OPTION_ARG" == true ]
                                then
                                        if [ -z "$OPTION_ARGS" ]
                                        then
                                                OPTION_ARGS+="$arg"
                                        else
                                                OPTION_ARGS+=" $arg"
                                        fi
                                fi
                                ;;
                esac
        done
        GRAB_NEXT_CMD_ARG=''
        GRAB_NEXT_OPTION_ARG=''

        if [[ $OPTION_COUNTER == 0 ]]
        then
                echo "ERROR: Please supply a valid option flag.  Type 'pfind -h' for usage."
                return 1
        elif [[ $OPTION_COUNTER > 1 ]]
        then
                #Check if multiple options are supported
                if [ "$MULTI_OPTION_SUPPORT" == false ]
                then
                        echo "ERROR: One or more of the input options ($OPTION_COUNTER selected) are not supported in tandem. Type 'pfind -h' for usage"
                        return 1
                fi
        fi

        if [ -z "$COMMAND_ARGS" ]
        then
                echo "ERROR: You must supply arguments for the options requested"
                return 1
        fi

        # For grepping multiple patterns recursively, remove the eval and quotes
        # Format command string to quote the user input
        #FIRST_C_ARG="$(echo "$COMMAND_ARGS" | awk '{print $1}')"
        #FIRST_C_ARG="$2"
        LAST_C_ARG="$(echo "$COMMAND_ARGS" | awk '{print $NF}')"
        # Trailing arguments for multi-arg greps
        if [[ $COMMAND_ARG_COUNTER > 1 ]]
        then
                FIRST_C_ARG="$(echo "$COMMAND_ARGS" | awk '{print $1}')"
                REMOVE_FIRST_ARG="${COMMAND_ARGS#* }"
        else
                FIRST_C_ARG="$COMMAND_ARGS"
                REMOVE_FIRST_ARG=''
        fi

        COMMAND_STR="$COMMAND_STR \"$FIRST_C_ARG\""

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
                # Make sure input is valid
                # This will not always be a line input
                SPEC_LINE="$LAST_C_ARG"
                if [[ -n ${SPEC_LINE//[0-9]/} ]]
                then
                        #echo "Bad line number specified, opening file at ln: 1"
                        # If no or a bad line is specified, ignore it
                        OPEN_SPEC_LINE='false'
                else
                        OPEN_SPEC_LINE='true'
                fi

                # TODO: implement version of this that opens line of grep readout! That would be baller as fuck.
                # Use input scanner to parse the grep result into an array
                IFS=$'\n'; FILES=($CMD_RES); unset IFS;

                # Open the file if only one result, ask the user which to open if more
                if [ ${#FILES[@]} == "1" ]
                then
                        OPEN_FILE="$FILES"
                else
                        echo "${#FILES[@]} files found with name $FIRST_C_ARG:"
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

                if [ "$REMOTE_BRANCH" == true ]
                then
                        if [ -z OPTION_ARGS ]
                        then
                                echo "Warning: no option arguments passed for sub option, dropping."
                        else
                                echo "Opening $OPEN_FILE on remote ref branch $OPTION_ARGS"
                                # Because vim doesn't like to load plugins before executing a -c call
                                # we need to get clever.  Thus, we run an autocmd script on VimEmter
                                # where we call a timer to wait 1 ms after startup before piping
                                # a string to a vim command callback function (see .vimrc).  Thus,
                                # we wait for the plugin to load.
                                vi -c ":autocmd VimEnter * call timer_start(100, function('CmdCallback',['Gedit $OPTION_ARGS:$OPEN_FILE']))"
                        fi
                elif [ $OPEN_SPEC_LINE == 'true' ]
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
                #echo "Calling: $COMMAND_STR ${@:3}"
                #eval $COMMAND_STR ${@:3}
                #echo "cmd_str=$COMMAND_STR - remv_first_arg=$REMOVE_FIRST_ARG"
                echo "Calling: $COMMAND_STR $REMOVE_FIRST_ARG"
                eval $COMMAND_STR $REMOVE_FIRST_ARG
        fi

        FILE_EXTENSIONS=''
        SPECIFIC_EXCLUSIONS=''
        EXCLUSION_STR=''
        COMMAND_STR=''
        FIRST_C_ARG=''
        LAST_C_ARG=''
        REMOVE_FIRST_ARG=''
        CUR_DIR=''
        OPEN_FILE=''
        CMD_RES=''
        OPEN_SPEC_LINE=''
        SPEC_LINE=''
        OPTION_COUNTER=''
        MULTI_OPTION_SUPPORT=''
        COMMAND_OPTION=''
        COMMAND_ARGS=''
        COMMAND_ARG_COUNTER=''
        REMOTE_BRANCH=''
        OPTION_ARGS=''
        return 0
}


#function for running pytest
ptest()
{

        requires_file=true
        requires_tb=true
        SETUP_TB_FILE_LOC="/home/mkali/work/purity/tools/tests/infra/ci/setup_testbed.py"
        #pytest ~/work/purity/tools/tests/core/torture/ac_setup.py --testbed=vm-mkali --test-only --ac-config /home/mkali/work/purity/tools/tests/core/torture/altered_carbon_configs/wssd.cfg --reset
        ALTERED_CARBON_FILE="~/work/purity/tools/tests/core/torture/ac_setup.py"
        AC_TARGET_VM="vm-mkali"
        AC_CONFIG="/home/mkali/work/purity/tools/tests/core/torture/altered_carbon_configs/wssd.cfg"


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
                        -ac|--altered-carbon)
                                # pytest ~/work/purity/tools/tests/core/torture/ac_setup.py --testbed=vm-mkali --test-only --ac-config /home/mkali/work/purity/tools/tests/core/torture/altered_carbon_configs/wssd.cfg --reset
                                COMMAND_STR-"$ALTERED_CARBON_FILE --testbed $AC_TARGET_VM --test-only --ac-config $AC_CONFIG --reset"
                                requires_file=false
                                requires_tb=false
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

        if [ -z "$TESTBED" -a "$requires_tb" == true ]
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
                        echo ""
                        #virtual_install
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
                        echo ""
                        #virtual_install;
                        #virtual_install_new
                fi

                echo "Calling: pytest $2 $COMMAND_STR"
                eval pytest "$2" $COMMAND_STR
        fi

        requires_tb=""
        requires_files=""
        AC_CONFIG=""
        ALTERED_CARBON_FILE=""
        AC_TARGET_VM=""
        #virtual_uninstall; #activate this if you want to hide the sourcing agent
}

# Function to get a passed range of commits as nice copy-pastable lines for excel or google sheets
get_pastable_commit_lines()
{


        if [ -z "$2" ]
        then
                echo "Error: You must supply a git range"
                echo "Usage: get_pastable_commit_lines hash_exclusive_start hash_inclusive_end"
                return 1
        fi

        echo "Getting pastable git log lines for the provided range ($1 - $2]"

        # CMD_STR="git log --oneline --pretty=format:"%h%x09%an%x09%s" --ancestry-path 3d247a2f7b0..e13706332243
}

