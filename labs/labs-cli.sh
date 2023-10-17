#!/usr/bin/env bash

#TODO: would it make more sense to do this in something like JS or Python?

pushd . > '/dev/null';
__LABS_DIR="${BASH_SOURCE[0]:-$0}";

while [ -h "$__LABS_DIR" ];
do
    cd "$( dirname -- "$__LABS_DIR"; )";
    __LABS_DIR="$( readlink -f -- "$__LABS_DIR"; )";
done

cd "$( dirname -- "$__LABS_DIR"; )" > '/dev/null';
__LABS_DIR="$( pwd; )";
popd  > '/dev/null';

labs() {
    # use the argument select a sub-command
    case $1 in
        list)
            __labs_list
            ;;
        show)
            __labs_show
            ;;
        setup)
            __labs_setup
            ;;
        check)
            __labs_check
            ;;
        solve)
            __labs_solve
            ;;
        -h|--help)
            __labs_usage
            ;;
        *)
            echo "Unknown command $1"
            __labs_usage
            ;;
    esac
}

__labs_usage() {
    echo "Usage: labs [options] <command>"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show help"
    echo ""
    echo "Commands:"
    echo "  list                    List available labs"
    echo "  show                    Shows the current in-progress lab"
    echo "  setup                   Sets up the current in-progress lab"
    echo "  check                   Checks the current in-progress lab"
    echo "  solve                   Solves the current in-progress lab"
}

__labs_show() {
    echo "-------------------------------------------------------------------------------------------------------"
    echo "| Lab #   | Description   | Status     | Path                                                         |"
    echo "| ------- | ------------- | ---------- | ------------------------------------------------------------ |"
    __lab_display "$(__labs_current)"
    echo "-------------------------------------------------------------------------------------------------------"
}

__labs_list() {
    echo "-------------------------------------------------------------------------------------------------------"
    echo "| Lab #   | Description   | Status     | Path                                                         |"
    echo "| ------- | ------------- | ---------- | ------------------------------------------------------------ |"
    for lab in $(ls -d $__LABS_DIR/*/); do
        __lab_display "$lab"
    done
    echo "-------------------------------------------------------------------------------------------------------"
}

__labs_setup() {
    local lab="$(__labs_current)"
    __lab_get "$lab"
    lab-${lab_number}-setup
}

__labs_check() {
    local lab="$(__labs_current)"
    __lab_get "$lab"
    lab-${lab_number}-check
}

__labs_solve() {
    local lab="$(__labs_current)"
    __lab_get "$lab"
    lab-${lab_number}-solve
}

__labs_current() {
    for lab in $(ls -d $__LABS_DIR/*/); do
        if [ ! -f $lab/.completed ]; then
            echo "$lab"
            break
        fi
    done
}

__lab_display() {
    __lab_get "$1"
    printf "| %-7s | %-13s | %-10s | %-60s |\n" $lab_number $lab_description $lab_status $lab_path
}

__lab_get() {
    lab="$1"
    lab_name=$(basename $lab)
    lab_number=$(echo $lab_name | cut -d'-' -f1)
    lab_description=$(echo $lab_name | cut -d'-' -f2-)

    # NOTE: use grealpath on Darwin
    # TODO: probably a better way to do this right?
    if [ "$(uname)" = "Darwin" ]; then
        lab_path=$(grealpath --relative-to=${PWD} $lab)
    else
        lab_path=$(realpath --relative-to=${PWD} $lab)
    fi

    if [ -f $lab/.completed ]; then
        lab_status='completed '
    else
        lab_status='incomplete'
    fi
}

# source all of the individual lab scripts
for lab in $(ls -d $__LABS_DIR/*/); do
    . "$lab/lab.sh"
done
