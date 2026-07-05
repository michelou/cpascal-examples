#!/usr/bin/env bash
#
# Copyright (c) 2018-2026 Stéphane Micheloud
#
# Licensed under the MIT License.
#

##############################################################################
## Subroutines

getHome() {
    local source="${BASH_SOURCE[0]}"
    while [[ -h "$source" ]]; do
        local linked="$(readlink "$source")"
        local dir="$( cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd )"
        source="$dir/$(basename "$linked")"
    done
    ( cd -P "$(dirname "$source")" && pwd )
}

debug() {
    local DEBUG_LABEL="[46m[DEBUG][0m"
    [[ $DEBUG -eq 1 ]] && echo "$DEBUG_LABEL $1" 1>&2
}

warning() {
    local WARNING_LABEL="[46m[WARNING][0m"
    echo "$WARNING_LABEL $1" 1>&2
}

error() {
    local ERROR_LABEL="[91mError:[0m"
    echo "$ERROR_LABEL $1" 1>&2
}

# use variables EXITCODE, TIMER_START
cleanup() {
    [[ $1 =~ ^[0-1]$ ]] && EXITCODE=$1

    if [[ $TIMER -eq 1 ]]; then
        local TIMER_END=$(date +'%s')
        local duration=$((TIMER_END - TIMER_START))
        echo "Total execution time: $(date -d @$duration +'%H:%M:%S')" 1>&2
    fi
    debug "EXITCODE=$EXITCODE"
    exit $EXITCODE
}

args() {
    [[ $# -eq 0 ]] && HELP=1 && return 1

    for arg in "$@"; do
        case "$arg" in
        ## options
        -debug)   DEBUG=1 ;;
        -help)    HELP=1 ;;
        -jvm)     TARGET="jvm" ;;
        -net)     TARGET="net" ;;
        -timer)   TIMER=1 ;;
        -verbose) VERBOSE=1 ;;
        -*)
            error "Unknown option \"$arg\""
            EXITCODE=1 && return 0
            ;;
        ## subcommands
        clean)   COMMANDS+=' clean' ;;
        compile) COMMANDS+=" compile_$TARGET" ;;
        help)    HELP=1 ;;
        run)     COMMANDS+=" compile_$TARGET run_$TARGET" ;;
        *)
            error "Unknown subcommand \"$arg\""
            EXITCODE=1 && return 0
            ;;
        esac
    done
    debug "Options    : TARGET=$TARGET TIMER=$TIMER VERBOSE=$VERBOSE"
    debug "Subcommands: $COMMANDS"
    debug "Variables  : \"CROOT=$CROOT\""
    debug "Variables  : GIT_HOME=$GIT_HOME"
    debug "Variables  : GPCP_HOME=$GPCP_HOME"
    debug "Variables  : JAVA_HOME=$JAVA_HOME"
    debug "Variables  : \"JROOT=$JROOT\""
    debug "Variables  : MAIN_NAME=$MAIN_NAME MAIN_ARGS=$MAIN_ARGS"
    # See http://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
    [[ $TIMER -eq 1 ]] && TIMER_START=$(date +"%s")
}

help() {
    cat << EOS
Usage: $BASENAME { <option> | <subcommand> }

  Options:
    -debug       print commands executed by this script
    -jvm         generate JVM code (instead of .NET executable)
    -net         generate .Net code (default)
    -timer       print total execution time
    -verbose     print progress messages

  Subcommands:
    clean        delete generated files
    compile      compile Ada source files
    help         print this help message
    run          execute the generated executable "$MAIN_NAME"
EOS
}

clean() {
    remove_dir "$TARGET_DIR"
}

remove_dir() {
    local dir=$1
    if [[ -d "$dir" ]]; then
        if [[ $DEBUG -eq 1 ]]; then
            debug "Delete directory \"$dir\""
        elif [[ $VERBOSE -eq 1 ]]; then
            echo "Delete directory \"${dir/$ROOT_DIR\//}\"" 1>&2
        fi
        rm -rf "$dir"
        [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
    fi
}

compile_jvm() {
    [[ -d "$CLASSES_DIR" ]] || mkdir -p "$CLASSES_DIR"

    ## Unix-style options: "-option" are recognized also
    local verbose_opts=
    if [[ $DEBUG -eq 1 ]]; then verbose_opts="-verbose";
    elif [[ $VERBOSE -eq 1 ]]; then verbose_opts="-quiet";
    else verbose_opts="-quiet -nowarn -list-";
    fi
    local gpcp_jvm_opts="$verbose_opts -asm8"
    local source_files=
    local n=0
    for f in $(find "$SOURCE_MAIN_DIR/" -type f -name "*.cp" 2>/dev/null); do
        source_files="$source_files \"../..${f/$ROOT_DIR/}\""
        n=$((n + 1))
    done
    if [[ $n -eq 0 ]]; then
        warning "No Component Pascal source file found"
        return 1
    fi
    local s=; [[ $n -gt 1 ]] && s="s"
    local n_files="$n Componet Pascal source file$s"
    pushd "$CLASSES_DIR" 1>/dev/null

    if [[ $DEBUG -eq 1 ]]; then
        debug "\"$GPCP_JVM_CMD\" $gpcp_opts $gpcp_jvm_opts $source_files"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Compile $n_files to directory \"${CLASSES_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    ## default is -asm7 for class files generation
    eval "\"$GPCP_JVM_CMD\" $gpcp_jvm_opts $source_files"
    if [[ $? -ne 0 ]]; then
        popd 1>/dev/null
        error "Failed to compile $n_files to directory \"${CLASSES_DIR/$ROOT_DIR\//}\""
        cleanup 1
    fi
    popd 1>/dev/null
}

compile_net() {
    [[ -d "$TARGET_DIR" ]] || mkdir -p "$TARGET_DIR"

    ## Unix-style options: "-option" are recognized also
    local verbose_opts=
    if [[ $DEBUG -eq 1 ]]; then verbose_opts="-verbose";
    elif [[ $VERBOSE -eq 1 ]]; then verbose_opts="-quiet";
    else verbose_opt=s"-quiet -nowarn -list-";
    fi
    local gpcp_net_opts="$verbose_opts -strict -target:$TARGET"

    local cpsym=$CPSYM
    export CPSYM=".$PSEP$JROOT/symfiles$PSEP$JROOT/symfiles/JvmSystem"

    local source_files=
    local n=0
    echo "0000000000 SOURCE_MAIN_DIR=$SOURCE_MAIN_DIR"
    find "$SOURCE_MAIN_DIR/" -type f -name "*.cp"
    echo "0000000000000000000"
    for f in $(find "$SOURCE_MAIN_DIR/" -type f -name "*.cp" 2>/dev/null); do
        echo "111111111 $f"
        source_files="$source_files \"$(mixed_path $f)\""
        n=$((n + 1))
    done
    if [[ $n -eq 0 ]]; then
        warning "No Component Pascal source file found"
        return 1
    fi
    local s=; [[ $n -gt 1 ]] && s="s"
    local n_files="$n Component Pascal source file$s"
    pushd $TARGET_DIR 1>/dev/null

    if [[ $DEBUG -eq 1 ]]; then
        debug "CPSYM=$CPSYM"
        debug "Current directory: $(mixed_path $PWD)"
        debug "\"$GPCP_NET_CMD\" $gpcp_net_opts $source_files"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Compile $n_files to directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "\"$GPCP_NET_CMD\" $gpcp_net_opts $source_files"
    if [[ $? -ne 0 ]]; then
        popd 1>/dev/null
        CPSYM=$cpsym
        error "Failed to compile $n_files to directory \"${TARGET_DIR/$ROOT_DIR\//}\" (DotNet)"
        cleanup 1
    fi
    popd 1>/dev/null
    CPSYM=$cpsym

    if [[ ! -f "$GPCP_HOME/bin/RTS.dll" ]]; then
        error "Runtime library not found"
        cleanup 1
    fi
    if [[ $DEBUG -eq 1 ]]; then
        debug "cp \"$GPCP_HOME/bin/RTS.dll\" \"$(mixed_path $TARGET_DIR)\""
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Copy runtime library to directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    cp "$GPCP_HOME/bin/RTS.dll" "$(mixed_path $TARGET_DIR/)"
    if [[ $? -ne 0 ]]; then
        error "Failed to copy runtime library to directory \"${TARGET_DIR/$ROOT_DIR\//}\""
        cleanup 1
    fi
}

mixed_path() {
    if [[ -x "$CYGPATH_CMD" ]]; then
        $CYGPATH_CMD -am "$*"
    elif [[ $(($mingw + $msys)) -gt 0 ]]; then
        echo "$*" | sed 's|/|\\\\|g'
    else
        echo "$*"
    fi
}

run_jvm() {
    local java_opts="-cp \"$JROOT/jars/cprts.jar;$(mixed_path $CLASSES_DIR)\""
    if [[ $DEBUG -eq 1 ]]; then
        debug "\"$JAVA_CMD\" $java_opts $MAIN_CLASS $MAIN_ARGS"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Execute main program \"$MAIN_CLASS\" $MAIN_ARGS" 1>&2
    fi
    eval "\"$JAVA_CMD\" $java_opts $MAIN_CLASS $MAIN_ARGS"
    if [[ $? -ne 0 ]]; then
        error "Failed to execute main program \"$MAIN_CLASS\"" 1>&2
        cleanup 1
    fi
}

run_net() {
    local exe_name="$MAIN_NAME$TARGET_EXT"
    local exe_file="$TARGET_DIR/$exe_name"
    if [[ ! -f "$exe_file" ]]; then
        error "Executable \"${exe_file/$ROOT_DIR\//}\" not found"
        cleanup 1
    fi
    if [[ $DEBUG -eq 1 ]]; then
        debug "$(mixed_path $exe_file) $MAIN_ARGS"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Execute main program \"${exe_file/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "\"$(mixed_path $exe_file)\" $MAIN_ARGS"
    if [[ $? -ne 0 ]]; then
        error "Failed to execute main program \"${exe_file/$ROOT_DIR\//}\"" 1>&2
        cleanup 1
    fi
}

##############################################################################
## Environment setup

BASENAME=$(basename "${BASH_SOURCE[0]}")

EXITCODE=0

ROOT_DIR="$(getHome)"

SOURCE_DIR="$ROOT_DIR/src"
SOURCE_MAIN_DIR="$SOURCE_DIR/main/cp"
TARGET_DIR="$ROOT_DIR/target"
CLASSES_DIR="$TARGET_DIR/classes"

## We refrain from using `true` and `false` which are Bash commands
## (see https://man7.org/linux/man-pages/man1/false.1.html)
COMMANDS=
DEBUG=0
HELP=0
TARGET=net
TIMER=0
VERBOSE=0

COLOR_START="[32m"
COLOR_END="[0m"

cygwin=0
mingw=0
msys=0
darwin=0
linux=0
case "$(uname -s)" in
    CYGWIN*) cygwin=1 ;;
    MINGW*)  mingw=1 ;;
    MSYS*)   msys=1 ;;
    Darwin*) darwin=1 ;;
    Linux*)  linux=1
esac
unset CYGPATH_CMD
if [[ $(($cygwin + $mingw + $msys)) -gt 0 ]]; then
    CYGPATH_CMD="$(which cygpath 2>/dev/null)"
    [[ -n "$GPCP_HOME" ]] && GPCP_HOME="$(mixed_path $GPCP_HOME)"
    [[ -n "$JAVA_HOME" ]] && JAVA_HOME="$(mixed_path $JAVA_HOME)"
    [[ -n "$JROOT" ]] && JROOT="$(mixed_path $JROOT)"
    TARGET_EXT=".exe"
	PSEP=";"
else
    TARGET_EXT=
    PSEP=":"
fi

if [[ ! -f "$JAVA_HOME/bin/java$TARGET_EXT" ]]; then
    error "Java SDK installation not found"
    cleanup 1
fi
JAVA_CMD="$JAVA_HOME/bin/java$TARGET_EXT"

if [[ ! -f "$JROOT/bin/gpcp.bat" ]]; then
    error "Component Pascal compiler for JVM not found"
    cleanup 1
fi
GPCP_JVM_CMD="$JROOT/bin/gpcp.bat" 

if [[ ! -f "$GPCP_HOME/bin/gpcp.exe" ]]; then
    error "Component Pascal compiler for .NET not found "
    cleanup 1
fi
GPCP_NET_CMD="$GPCP_HOME/bin/gpcp.exe"

PROJECT_NAME="$(basename $ROOT_DIR)"

MAIN_NAME=Hello
MAIN_CLASS=CP.Hello.$MAIN_NAME
MAIN_ARGS=

args "$@"
[[ $EXITCODE -eq 0 ]] || cleanup 1

##############################################################################
## Main

[[ $HELP -eq 1 ]] && help && cleanup

for cmd in $COMMANDS; do
   $cmd
   [[ $EXITCODE -eq 0 ]] || cleanup 1
done
cleanup
