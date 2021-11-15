#!/bin/bash

control_func() {
echo "Starting powercontrol script"

SHELF_POWER_CMD="powercontrol.py"
CHASSIS_POWER_CMD="platinum_bay"
#platinum_bay power_off fm 4
#powercontrol off encl_id SH8 FMB10
if [ -z "$1" ]
then
        echo "Error: Please supply -h flag for help"
        return 0
else
        case "$1" in
                --on)
                        echo "Turning on drives in all external shelves"
                        echo " "
                        SHELF_POWER_CMD="$SHELF_POWER_CMD on"
                        CHASSIS_POWER_CMD="$CHASSIS_POWER_CMD power_on"
                        ;;
                --off)
                        echo "Turnning off drives in all external shelves"
                        SHELF_POWER_CMD="$SHELF_POWER_CMD off"
                        CHASSIS_POWER_CMD="$CHASSIS_POWER_CMD power_off"
                        ;;
                -h|--help)
                        echo "Powercontrol helper script for chassis and shelves."
                        echo "****************************"
                        echo "USAGE: ./power_shelves.sh [power option] [target shelves]"
                        echo "EXAMPLE: ./power_shelves.sh --off SH8 CH0 SH9"
                        echo "****************************"
                        echo "Options for ARG 1:"
                        echo " -h | --help = Get help, print some explanation lines"
                        echo " --on = turn all devices on"
                        echo " --off = turn all devices off"
                        echo ""
                        return 0
                        ;;
                *)
                        echo "ERROR: argument $1 not supported.  Use -h for help."
                        echo ""
                        return 0
                        ;;
        esac
fi

SHELF_ARRAY=()
TARGET_CHASSIS='false'

if [ -z "$2" ]
then
        echo "Error: Please supply targeted shelf shortnames"
        return 0
else
        for shelf in "${@:2}"
        do
            if [[ $shelf == "CH"* ]]
            then
                TARGET_CHASSIS='true'
                echo "Targeting chassis CH0"
            else
                echo "Targeting $shelf"
                SHELF_ARRAY+=("$shelf")
            fi
        done
fi

# powercontrol on chassis
if [[ $TARGET_CHASSIS == "true" ]]
then
    # Drives
    for num in {0..19}
    do
        CUR_CMD="$CHASSIS_POWER_CMD fm $num"
        echo $CUR_CMD
        $CUR_CMD
    done
    # NVRAMS
    for num in {0..3}
    do
        CUR_CMD="$CHASSIS_POWER_CMD nvram $num"
        echo $CUR_CMD
        $CUR_CMD
    done
fi

# Powercontrol on shelves
for arr in "${SHELF_ARRAY[@]}"
do
    for num in {0..27}
    do
        CUR_CMD="$SHELF_POWER_CMD encl_id $arr FMB$num"
        echo $CUR_CMD
        $CUR_CMD
    done
done


CUR_CMD=''
SHELF_ARRAY=''
SHELF_POWER_CMD=''
CHASSIS_POWER_CMD=''

}

control_func $@

