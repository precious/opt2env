# https://github.com/precious
# you can use this code without any restrictions

function __get_var_name {
    # arguments: OPTION, ARRAY
    # ARRAY -- each element is like '-f|--foo|...|{FOO}',
    # where -f, --foo, ... -- names of options
    #   FOO -- name of environment variable to be set
    # OPTION -- option like '-f' or '--foo'
    # function returns variable name for given option
    option="$1"
    shift
    should_stop=""
    # assumed that IFS is set to space
    for args in "$@"; do
        parts=(${args//|/ }) # here parts will be array like ("-f" "--foo" "FOO")
        for part in ${parts[@]:0:$[${#parts[@]} - 1]}; do
            if [ "$part" == "$option" ]; then
                # return last element without leftmost and rightmost characters
                echo ${parts[$[${#parts[@]} - 1]]:1:-1}
                should_stop="yes"
                break
            fi
        done
        if [ -n "$should_stop" ]; then
            break
        fi
    done
}

function echo_help {
    echo $1 $'\n'
    echo $2 | grep -Po '(?<=\[)[^]]+(?=\])' | sed 's/|{[^}]*}//' | sed "s/^/    /"
    echo "    -h|--help print help"
}

function opt2env {
    __USAGE=$1
    __DOCSTRING=$2
    shift 2 # skip docstring and usage
    __PREV_IFS="$IFS" # backup IFS
    IFS=$'\n' # set new IFS
    __PARAMS=`echo $__DOCSTRING | grep -Po '(?<=\[)[^]]+(?=\])'`
    req_arg=() # array of options that require arguments
    not_req_arg=() # array of options that don't require arguments
    for __P in $__PARAMS; do
        words=(${__P// /$'\n'}) # split param by spaces
        if (( ${#words[@]} > 0 )); then
            if (( ${#words[@]} > 1 )); then
                if echo ${words[1]} | grep -P '^<[^>]+>$' > /dev/null 2>1; then # option requires argument
                    req_arg+=("${words[0]}")
                else # option doesn't require argument
                    not_req_arg+=("${words[0]}")
                fi
            else # option doesn't require argument
                not_req_arg+=("${words[0]}")
            fi
        fi
    done
    
    IFS=' '
    FREE_ARGUMENTS=()
    while [ $# -gt 0 ] ; do # iterate over command line arguments and set appropriate environment variables
        if [ "$1" == "-h" -o "$1" == "--help" ]; then # just echo help and exit
            echo_help "$__USAGE" "$__DOCSTRING"
            exit 0
        fi
        if [ "${1:0:1}" == "-" ]; then # option should start with "-"
            varname=`__get_var_name "$1" "${not_req_arg[@]}"`
            if [ -n "$varname" ]; then # switch option
                eval "$varname=1"
                shift
                continue
            fi
            varname=`__get_var_name "$1" "${req_arg[@]}"`
            if [ -n "$varname" ]; then # parametrised argument
                if [ $# -gt 1 -a "${2:0:1}" != "-" ]; then
                    eval "$varname=\"$2\""
                    shift 2
                    continue
                else # invalid command line options
                    echo -e "error: '${1}' requires parameter\ntry --help or -h option for help"
                    exit 1
                fi
            fi
            # we encountered options that was not declared
            echo -e "error: unrecognized option '${1}'\ntry --help or -h option for help"
            exit 1
        else
            FREE_ARGUMENTS+=("$1")
            shift
        fi
    done
    IFS="$__PREV_IFS" # restore IFS
}
