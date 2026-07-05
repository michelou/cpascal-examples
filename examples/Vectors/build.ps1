#!/usr/bin/env pwsh
#
# Copyright (c) 2018-2026 Stéphane Micheloud
#
# Licensed under the MIT License.
#

## only for interactive debugging !
$DEBUG = $false

#########################################################################
## Environment setup

$EXITCODE = 0

$EXE = ""
if ($PSVersionTable.PSVersion -lt "6.0" -or $IsWindows) {
  # Fix case when both the Windows and Linux builds of this program
  # are installed in the same directory.
  $EXE = '.exe'
}

$BASENAME = (Get-Item $PSScriptRoot).Basename
$ROOT_DIR = $PSScriptRoot
$PATH_SEP = [IO.Path]::PathSeparator
$SEP = [IO.Path]::DirectorySeparatorChar

$SOURCE_DIR = $ROOT_DIR + $SEP + 'src'
$SOURCE_MAIN_DIR = $SOURCE_DIR + $SEP + 'main' + $SEP + 'cp'
$TARGET_DIR = $ROOT_DIR + $SEP + 'target'

if (! (Test-Path -PathType Leaf -Path ($Env:GPCP_HOME + $SEP + 'bin' + $SEP + 'gpcp' + $EXE))) {
    Write-Error "Garden Points CP installation not found ($Env:GPCP_HOME)"
    $EXITCODE = 1
    Cleanup $EXITCODE
}
$GPCP_NET_CMD = $Env:GPCP_HOME + $SEP + 'bin' + $SEP + 'gpcp' + $EXE

#########################################################################
## Script arguments

$COMMANDS = @()

## Possible values: SilentlyContinue, Stop, Continue, Inquire, Ignore, Suspend
$DebugPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$WarningPreference = 'Continue'

$HELP = $false
$TARGET = 'net'
$TIMER = $false
$VERBOSE = $false
$N = 0
foreach ($ARG in $args) {
    if ($ARG.StartsWith("-")) {
        ## option
        if ($ARG -ieq '-debug') { $DEBUG = $true; $DebugPreference='Continue'
        } elseif ($ARG -ieq '-help'   ) { $HELP = $true
        } elseif ($ARG -ieq '-jvm'    ) { $TARGET = 'jvm'
        } elseif ($ARG -ieq '-net'    ) { $TARGET = 'net'
        } elseif ($ARG -ieq '-timer'  ) { $TIMER = $true
        } elseif ($ARG -ieq '-verbose') { $VERBOSE = $true; $VerbosePreference = 'Continue'
        } else {
            Write-Error "Unknown option ""$ARG"""
            $EXITCODE = 1
            break
        }
    } else {
        ## subcommand
        if ($ARG -ieq 'clean') { $COMMANDS += 'Clean'
        } elseif ($ARG -ieq 'compile') { $COMMANDS += 'Compile'
        } elseif ($ARG -ieq "help") { $HELP = $true
        } elseif ($ARG -ieq "run" ) { $COMMANDS += 'Compile', 'Run'
        } else {
            Write-Error "Unknown subcommand ""$ARG"""
            $EXITCODE = 1
            break
        }
        $N++
    }
}
$MAIN_NAME = 'Vector'
$MAIN_CLASS = "CP.Vector.$MAIN_NAME"
$MAIN_ARGS = $null

$SOURCE_MAIN_FILE = $SOURCE_MAIN_DIR + $SEP + $MAIN_NAME + '.cp'
$PROJECT_NAME = $BASENAME
$EXE_FILE = $TARGET_DIR + $SEP + $PROJECT_NAME + $EXE

Write-Debug "Options    : DEBUG=$DEBUG HELP=$HELP TIMER=$TIMER VERBOSE=$VERBOSE"
Write-Debug "Subcommands: $COMMANDS"
Write-Debug "Variables  : ""CROOT=$Env:CROOT"""
Write-Debug "Variables  : ""GIT_HOME=$Env:GIT_HOME"""
Write-Debug "Variables  : ""JAVA_HOME=$Env:JAVA_HOME"""
Write-Debug "Variables  : ""JROOT=$Env:JROOT"""
Write-Debug "Variables  : MAIN_NAME=$MAIN_NAME MAIN_ARGS=$MAIN_ARGS"
Write-Debug "Variables  : PROJECT_NAME=$PROJECT_NAME"

if ($TIMER) { $TIMER_START = Get-Date }

#########################################################################
## Subroutines

function Main
{
    if ($HELP) {
        Print-Help
        Cleanup 0
    }
    foreach($COMMAND in $COMMANDS) {
        &$COMMAND
        if ($EXITCODE -ne 0) { exit $EXITCODE }
    }
    if ($TIMER) {
        $DURATION = New-TimeSpan -Start $TIMER_START -End (Get-Date)
        Write-Output "Total execution time: $DURATION"
    }
    Cleanup $EXITCODE
}

function Print-Help
{
    Write-Output "Usage: $BASENAME { <option> | <subcommand> }"
    Write-Output ""
    Write-Output "   Options:"
    Write-Output "     -debug      print commands executed by this script"
    Write-Output "     -jvm        generate JVM code (instead of .NET executable)"
    Write-Output "     -net        generate .Net code (default)"
    Write-Output "     -timer      print total execution time"
    Write-Output "     -verbose    print progress messages"
    Write-Output ""
    Write-Output "   Subcommands:"
    Write-Output "     clean       delete generated files"
    Write-Output "     compile     compile Component Pascal source files"
    Write-Output "     help        print this help message"
    Write-Output "     run         execute main program ""$MAIN_NAME"""
}

function Clean
{
    Delete-Dir $TARGET_DIR
}

function Delete-Dir
{
    param (
        [string] $dir
    )
    if (Test-Path -PathType Container -Path $dir) {
        Write-Debug "[System.IO.Directory]::Delete('$dir', $true)"
        Write-Verbose "Delete directory ""$($dir.Replace($ROOT_DIR + $SEP, ''))"""
        #Remove-Item -Path $dir -Force -Recurse
        try {
            [System.IO.Directory]::Delete($dir, $true)
        } catch {
            Write-Error "Failed to delete directory ""$($dir.Replace($ROOT_DIR + $SEP, ''))"""
            $EXITCODE = 1
            return
        }
    }
}

function Compile
{
    if (! (Test-Path -PathType Container -Path $TARGET_DIR)) {
        $_ = New-Item -ItemType Directory -Path $TARGET_DIR
    }
    $SOURCE_FILES = Get-ChildItem -Path "$SOURCE_MAIN_DIR" -Include "*.cp" -Recurse
    $N = $SOURCE_FILES.Count
    if ($N -eq 0) {
        Write-Warning "No Component Pascal source file found"
        return 0
    } elseif ($N -eq 1) { $N_FILES = "$N Component Pascal source file"
    } else { $N_FILES = "$N Component Pascal source files"
    }
    if ($DEBUG) { $VERBOSE_OPTS = @('-verbose')
    } elseif ($VERBOSE) { $VERBOSE_OPTS = @('-quiet')
    } else { $VERBOSE_OPTS = @('-quiet', '-nowarn', '-list-')
    }
    $GPCP_NET_OPTS = $($VERBOSE_OPTS; @("-target:$TARGET"))

    $CPSYM = $Env:CPSYM
    $Env:CPSYM = '.' + $PATH_SEP + $Env:JROOT + $SEP + 'symfiles' + $PATH_SEP + $Env:JROOT + $SEP + 'symfiles' + $SEP + 'JvmSystem'

    pushd $TARGET_DIR
    Write-Debug "CPSYM=$Env:CPSYM"
    Write-Debug "Current directory: $PWD"
    Write-Debug """$GPCP_NET_CMD"" $GPCP_NET_OPTS $SOURCE_FILES"
    Write-Verbose "Compile $N_FILES to directory ""$($TARGET_DIR.Replace($ROOT_DIR + $SEP, ''))"""
    &"$GPCP_NET_CMD" $GPCP_NET_OPTS $SOURCE_FILES
    if ($LASTEXITCODE -ne 0) {
        popd
        $Env:CPSYM = $CPSYM
        Write-Error "Failed to compile $N_FILES to directory ""$($TARGET_DIR.Replace($ROOT_DIR +$SEP, ''))"""
        $EXITCODE = 1
        return 0
    }
    popd
    $Env:CPSYM = $CPSYM

    $RTS_FILE = $Env:GPCP_HOME + $SEP + 'bin' + $SEP + 'RTS.dll'
    if (! (Test-Path -PathType Leaf -Path $RTS_FILE)) {
        Write-Error "Runtime library not found"
        Cleanup 1
    }
    Write-Debug "Copy-Item -Path ""$RTS_FILE"" -Destination ""$TARGET_DIR"""
    Write-Verbose "Copy runtime library to directory ""$TARGET_DIR"""
    Copy-Item -Path $RTS_FILE -Destination $TARGET_DIR
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to copy runtime library to directory ""$($TARGET_DIR.Replace($ROOT_DIR + $SEP, ''))"""
        Cleanup 1
    }
}

function Run
{
    if (! (Test-Path -PathType Leaf -Path $EXE_FILE)) {
        Write-Error "Main program ""$PROJECT_NAME"" not found ($EXE_FILE)"
        $EXITCODE = 1
        return 0
    }
    Write-Debug """$EXE_FILE"" $MAIN_ARGS"
    Write-Verbose "Execute Component Pascal program ""$($EXE_FILE.Replace($ROOT_DIR + $SEP, ''))"""
    &$EXE_FILE $MAIN_ARGS
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to execute Component Pascal program ""$($EXE_FILE.Replace($ROOT_DIR, ''))"""
        $EXITCODE = 1
        return 0
    }
}

function Cleanup
{
    param (
        [int] $ExitCode
    )
    Write-Debug "ExitCode=$ExitCode"
    exit $ExitCode
}

#########################################################################
## Entry-point

Main
