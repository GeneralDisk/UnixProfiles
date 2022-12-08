# Bash functions file

HOME="/Users/mkali"

# This function clears all known_hosts from our ssh config
sshclear()
{
        SSH_DIR="$HOME/.ssh"

        echo "Resetting known_hosts file."

        rm $SSH_DIR/known_hosts
        cp $SSH_DIR/known_hosts_template $SSH_DIR/known_hosts

        echo "Done."

        SSH_DIR=''
}

# This function sends a preset log file to my vm
send_logs()
{
        LOG_DIR="/Users/mkali/Downloads/Logs"
        LOG_FILE="result.txt.gz"
        UNZIPPED_FILE="result.txt"

        # Unzip and send
        gunzip "$LOG_DIR/$LOG_FILE"

        echo "Sending $UNZIPPED_FILE"
        scp "$LOG_DIR/$UNZIPPED_FILE" "mkali@dev-mkali:~"

        echo "Cleaning up"
        rm "$LOG_DIR/$LOG_FILE"
        #rm "$LOG_DIR/$UNZIPPED_FILE"
}

# rudimentary update middleware function
update_middleware()
{

        COMPILE_LIB=''
        SCP_LIB=''
        SCP_PAWS=''
        CONTROLLER_0=''
        CONTROLLER_1=''
        PAWS_AUTH_FILE='/Users/mkali/Work/purity/paws/scripts/common_dev_key.pem'
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
                                echo "-up, --update-paws        compile and send middleware binaries to a paws target"
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
                                COMPILE_LIB="./middleware/sbin/build_middleware.sh"
                                CONTROLLER_0="$TARGET_ARRAY-ct0"
                                CONTROLLER_1="$TARGET_ARRAY-ct1"
                                SCP_LIB_0="scp middleware/target/*.jar root@$CONTROLLER_0:/opt/Purity/middleware/"
                                SCP_LIB_1="scp middleware/target/*.jar root@$CONTROLLER_1:/opt/Purity/middleware/"
                                ;;
                        -up|--update-paws)
                                COMPILE_LIB="./middleware/sbin/build_middleware.sh"
                                SCP_PAWS="scp -i $PAWS_AUTH_FILE middleware/target/*.jar root@$TARGET_ARRAY:/opt/Purity/middleware/"
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
        if [ -z "$SCP_LIB_0" ]
        then
                echo "Not sending to ct0 or ct1"
        else
                echo "Running: $SCP_LIB_0"
                $SCP_LIB_0
                echo "Running: $SCP_LIB_1"
                $SCP_LIB_1
        fi

        if [ -z "$SCP_PAWS" ]
        then
                echo "This is not a paws array"
        else
                echo "Running: $SCP_PAWS"
                $SCP_PAWS
        fi

        echo "Done."

        SCP_PAWS=''
        SCP_LIB_0=''
        SCP_LIB_1=''
        PAWS_AUTH_FILE=''
        return 0
}

plog()
{
        LOG_DIR="$HOME/Downloads/Logs"
        COMMAND_STR=''

        if [ -z "$1" ]
        then
                cd "$LOG_DIR";
                return 0
        else
                case "$1" in
                        -h|--help)
                                echo "*** plog command: helper for managing pure log files ***"
                                echo " "
                                echo "plog [option]"
                                echo " "
                                echo "options:"
                                echo "[None]                    cd to $LOG_DIR"
                                echo "-h, --help                show brief help"
                                echo "-c, --clean               clean the log folder"
                                echo "-u, --unzip               cd and unzip all .gz files"
                                echo " "
                                return 0
                                ;;
                        -c|--clean)
                                echo "Removing all files from $LOG_DIR"
                                rm -rf $LOG_DIR/*
                                return 0
                                ;;
                        -u|--unzip)
                                COMMAND_STR="gunzip *.gz"
                                ;;
                        *)
                                echo "Invalid argument flag passed.  Use -h for options"
                                return 1
                                ;;
                esac
        fi

        if [ -z "$COMMAND_STR" ]
        then
                return 0
        else
                echo "Moving to $LOG_DIR and executing $COMMAND_STR"
                cd $LOG_DIR
                $COMMAND_STR
                echo "Log Dir Contents:"
                ls -al
                return 0
        fi
}

