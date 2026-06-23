@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if %_HELP%==1 (
    call :help
    goto end
)
if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_COMPILE%==1 (
    call :compile_%_TARGET%
    if not !_EXITCODE!==0 goto end
)
if %_RUN%==1 (
    call :run_%_TARGET%
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _MAIN_NAME
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

set "_SOURCE_DIR=%_ROOT_DIR%src"
set "_SOURCE_MAIN_DIR=%_SOURCE_DIR%\main\cp"
set "_TARGET_DIR=%_ROOT_DIR%target"
set "_CLASSES_DIR=%_TARGET_DIR%\classes"

if not exist "%JAVA_HOME%\bin\java.exe" (
    echo %_ERROR_LABEL% Java SDK installation not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_JAVA_CMD=%JAVA_HOME%\bin\java.exe"

if not exist "%JROOT%\bin\gpcp.bat" (
    echo %_ERROR_LABEL% Component Pascal compiler for JVM not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GPCP_JVM_CMD=%JROOT%\bin\gpcp.bat"

if not exist "%GPCP_HOME%\bin\gpcp.exe" (
    echo %_ERROR_LABEL% Component Pascal compiler for .NET not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GPCP_NET_CMD=%GPCP_HOME%\bin\gpcp.exe"

@rem we use the newer PowerShell version if available
where /q pwsh.exe
if %ERRORLEVEL%==0 ( set _PWSH_CMD=pwsh.exe
) else ( set _PWSH_CMD=powershell.exe
)
@rem target=net
set _MAIN_NAME=TypeNames
@rem target=jvm
set _MAIN_CLASS=CP.TypeNames.%_MAIN_NAME%
set _MAIN_ARGS=
goto :eof

:env_colors
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd

@rem normal foreground colors
set _NORMAL_FG_BLACK=[30m
set _NORMAL_FG_RED=[31m
set _NORMAL_FG_GREEN=[32m
set _NORMAL_FG_YELLOW=[33m
set _NORMAL_FG_BLUE=[34m
set _NORMAL_FG_MAGENTA=[35m
set _NORMAL_FG_CYAN=[36m
set _NORMAL_FG_WHITE=[37m

@rem normal background colors
set _NORMAL_BG_BLACK=[40m
set _NORMAL_BG_RED=[41m
set _NORMAL_BG_GREEN=[42m
set _NORMAL_BG_YELLOW=[43m
set _NORMAL_BG_BLUE=[44m
set _NORMAL_BG_MAGENTA=[45m
set _NORMAL_BG_CYAN=[46m
set _NORMAL_BG_WHITE=[47m

@rem strong foreground colors
set _STRONG_FG_BLACK=[90m
set _STRONG_FG_RED=[91m
set _STRONG_FG_GREEN=[92m
set _STRONG_FG_YELLOW=[93m
set _STRONG_FG_BLUE=[94m
set _STRONG_FG_MAGENTA=[95m
set _STRONG_FG_CYAN=[96m
set _STRONG_FG_WHITE=[97m

@rem strong background colors
set _STRONG_BG_BLACK=[100m
set _STRONG_BG_RED=[101m
set _STRONG_BG_GREEN=[102m
set _STRONG_BG_YELLOW=[103m
set _STRONG_BG_BLUE=[104m

@rem we define _RESET in last position to avoid crazy console output with type command
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m
set _RESET=[0m
goto :eof

:args
set _CLEAN=0
set _COMPILE=0
set _HELP=0
set _RUN=0
set _TARGET=net
set _TIMER=0
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-help" ( set _HELP=1
    ) else if "%__ARG%"=="-jvm" ( set _TARGET=jvm
    ) else if "%__ARG%"=="-net" ( set _TARGET=net
    ) else if "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="clean" ( set _CLEAN=1
    ) else if "%__ARG%"=="compile" ( set _COMPILE=1
    ) else if "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto args_loop
:args_done
set _REDIRECT_STDOUT=1^>NUL
if %_DEBUG%==1 set _REDIRECT_STDOUT=

if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _TARGET=%_TARGET% _TIMER=%_TIMER% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Variables  : "CROOT=%CROOT%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "GIT_HOME=%GIT_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "GPCP_HOME=%GPCP_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "JAVA_HOME=%JAVA_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "JROOT=%JROOT%" 1>&2
)
if %_TIMER%==1 for /f "delims=" %%i in ('call "%_PWSH_CMD%" -c "(Get-Date)"') do set _TIMER_START=%%i
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%
    set __BEG_O=%_STRONG_FG_GREEN%
    set __BEG_N=%_NORMAL_FG_YELLOW%
    set __END=%_RESET%
) else (
    set __BEG_P=
    set __BEG_O=
    set __BEG_N=
    set __END=
)
echo Usage: %__BEG_O%%_BASENAME% { ^<option^> ^| ^<subcommand^> }%__END%
echo.
echo   %__BEG_P%Options:%__END%
echo     %__BEG_O%-debug%__END%      print commands executed by this script
echo     %__BEG_O%-jvm%__END%        generate JVM code ^(instead of .NET executable^)
echo     %__BEG_O%-net%__END%        generate .Net code ^(default^)
echo     %__BEG_O%-timer%__END%      print total execution time
echo     %__BEG_O%-verbose%__END%    print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%clean%__END%       delete generated class files
echo     %__BEG_O%compile%__END%     compile Component Pascal source files
echo     %__BEG_O%help%__END%        print this help message
echo     %__BEG_O%run%__END%         execute program "%_MAIN_NAME%"
goto :eof

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

@rem input parameter: %1=directory path
:rmdir
set "__DIR=%~1"
if not exist "%__DIR%\" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "%__DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile_jvm
if not exist "%_CLASSES_DIR%" mkdir "%_CLASSES_DIR%"

if %_DEBUG%==1 ( set __GPCP_OPTS=-verbose
) else if %_VERBOSE%==1 ( set __GPCP_OPTS=-quiet
) else ( set __GPCP_OPTS=-quiet -nowarn -list-
)
@rem default is -asm7 for class files generation
set __GPCP_OPTS=%__GPCP_OPTS% -asm8

@rem source file paths relative to directory 'target\classes\'
set __SOURCE_FILES=
set __N=0
for /f "delims=" %%f in ('dir /b "%_SOURCE_MAIN_DIR%\*.cp" 2^>NUL') do (
    set __SOURCE_FILES=!__SOURCE_FILES! "..\..\!_SOURCE_MAIN_DIR:%_ROOT_DIR%=!\%%f"
    set /a __N+=1
)
if %__N%==0 (
    echo %_WARNING_LABEL% No Component Pascal source files found 1>&2
    goto :eof
) else if %__N%==1 ( set __N_FILES=%__N% Component Pascal source file
) else ( set __N_FILES=%__N% Component Pascal source files
)
pushd "%_CLASSES_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GPCP_JVM_CMD%" %__GPCP_OPTS% %__SOURCE_FILES% 1>&2
) else if %_VERBOSE%==1 ( echo Compile %__N_FILES% to directory "!_CLASSES_DIR:%_ROOT_DIR%\=!" 1>&2
)
call "%_GPCP_JVM_CMD%" %__GPCP_OPTS% %__SOURCE_FILES%
if not %ERRORLEVEL%==0 (
    popd
    echo %_ERROR_LABEL% Failed to compile %__N_FILES% to directory "!_CLASSES_DIR:%_ROOT_DIR%\=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
goto :eof

:compile_net
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

if %_DEBUG%==1 ( set __GPCP_OPTS=-verbose
) else if %_VERBOSE%==1 ( set __GPCP_OPTS=
) else ( set __GPCP_OPTS=-quiet -nowarn
)
set __GPCP_OPTS=%__GPCP_OPTS% -target:%_TARGET%

set "__CPSYM=%CPSYM%"
set CPSYM=".;%JRoot%\symfiles;%JRoot%\symfiles\JvmSystem"

@rem source file paths relative to directory 'target\classes\'
set __SOURCE_FILES=
set __N=0
for /f "delims=" %%f in ('dir /b /s "%_SOURCE_MAIN_DIR%\*.cp" 2^>NUL') do (
    set __SOURCE_FILES=!__SOURCE_FILES! "%%f"
    set /a __N+=1
)
if %__N%==0 (
    echo %_WARNING_LABEL% No Component Pascal source files found 1>&2
    goto :eof
) else if %__N%==1 ( set __N_FILES=%__N% Component Pascal source file
) else ( set __N_FILES=%__N% Component Pascal source files
)
pushd "%_TARGET_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_GPCP_NET_CMD%" %__GPCP_OPTS% %__SOURCE_FILES% 1>&2
) else if %_VERBOSE%==1 ( echo Compile %__N_FILES% to directory "!_TARGET_DIR:%_ROOT_DIR%\=!" ^(DotNet^) 1>&2
)
call "%_GPCP_NET_CMD%" %__GPCP_OPTS% %__SOURCE_FILES% %_REDIRECT_STDOUT%
if not %ERRORLEVEL%==0 (
    popd
    set "CPSYM=%__CPSYM%"
    echo %_ERROR_LABEL% Failed to compile %__N_FILES% to directory "!_TARGET_DIR:%_ROOT_DIR%\=!" ^(DotNet^) 1>&2
    set _EXITCODE=1
    goto :eof
)
popd
set "CPSYM=%__CPSYM%"

if not exist "%GPCP_HOME%\bin\RTS.dll" (
    echo %_ERROR_LABEL% Runtime library not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% copy "%GPCP_HOME%\bin\RTS.dll" "%_TARGET_DIR%\" 1>&2
) else if %_VERBOSE%== ( echo Copy runtime library to directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
)
copy "%GPCP_HOME%\bin\RTS.dll" "%_TARGET_DIR%\" %_REDIRECT_STDOUT%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to copy runtime library to directory "!_TARGET_DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run_jvm
set __JAVA_OPTS=-cp "%JROOT%\jars\cprts.jar;%_CLASSES_DIR%"

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%_JAVA_CMD%" %__JAVA_OPTS% %_MAIN_CLASS% %_MAIN_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Execute main program "%_MAIN_CLASS%" %_MAIN_ARGS% 1>&2
)
call "%_JAVA_CMD%" %__JAVA_OPTS% %_MAIN_CLASS% %_MAIN_ARGS%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to execute main program "%_MAIN_CLASS%" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:run_net
set "__EXE_NAME=%_MAIN_NAME%.exe"
set "__EXE_FILE=%_TARGET_DIR%\%__EXE_NAME%"
if not exist "%__EXE_FILE%" (
    echo %_ERROR_LABEL% Executable "%_MAIN_NAME%.exe" not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "%__EXE_FILE%" %_MAIN_ARGS% 1>&2
) else if %_VERBOSE%==1 ( echo Execute main program "%__EXE_NAME%" 1>&2
)
call "%__EXE_FILE%" %_MAIN_ARGS%
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to execute main program "%__EXE_NAME%" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
