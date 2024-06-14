#!/bin/bash

VERSION="1.0"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# convert bytes to megabytes

mbconvert() {
    echo "scale=2; $1 / (1024 * 1024)" | bc
}

# show help

display_help() {
    echo -e "${YELLOW}Usage: $0 [options]${NC}"
    echo -e "${YELLOW}Options:${NC}"
    echo -e "  -h, --help      Display this help message"
    echo -e "  -v, --version   Display the script version"
    echo -e "  -p, --parse     Output results in a script-friendly format"
}

# run disk test

runtest() {
    local operation=$1
    local bs=$2
    local count=$3
    local file=$4
    local output

    if [[ $operation == "write" ]]; then
        output=$( (time dd if=/dev/zero bs=$bs of=$file count=$count) 2>&1)
    elif [[ $operation == "read" ]]; then
        output=$(dd if=$file bs=$bs of=/dev/null count=$count 2>&1)
    else
        echo -e "${RED}Invalid operation: $operation${NC}"
        exit 1
    fi

    echo "$output"
}

# parse speed from stdout
speedparse() {
    local output=$1
    echo "$output" | awk -F'[()]' '/bytes transferred/ {print $2}' | awk '{print $1}'
}

main() {
    local PARSE_MODE=false

    # check for options
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -h|--help)
                display_help
                exit 0
                ;;
            -v|--version)
                echo "diskspeed, v$VERSION"
                exit 0
                ;;
            -p|--parse)
                PARSE_MODE=true
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                display_help
                exit 1
                ;;
        esac
        shift
    done

    # write test
    write_output=$(runtest "write" "1024k" "1024" "disktest")
    # get write speed
    write_speed=$(speedparse "$write_output")

    # sleep 3 for disk to rest
    sleep 3

    # read test
    read_output=$(runtest "read" "1024k" "1024" "disktest")
    # get read speed
    read_speed=$(speedparse "$read_output")

    # convert to MB
    write_speed_mb=$(mbconvert "$write_speed")
    read_speed_mb=$(mbconvert "$read_speed")

    # show results
    if $PARSE_MODE; then
        echo "write_speed_mb=${write_speed_mb}"
        echo "read_speed_mb=${read_speed_mb}"
    else
        echo -e "${GREEN}Write speed: ${write_speed_mb} MB/sec${NC}"
        echo -e "${BLUE}Read speed: ${read_speed_mb} MB/sec${NC}"
    fi

    # delete test file
    rm disktest
}

# run script
main "$@"