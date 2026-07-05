@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging
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
    exit /b !_EXITCODE!
)

set _GIT_PATH=
set _MSYS_PATH=

call :gpcp_net
if not %_EXITCODE%==0 goto end

call :gpcp_jvm
if not %_EXITCODE%==0 goto end

call :java 17 "temurin"
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

call :msys
if not %_EXITCODE%==0 goto end

if "%~1"=="clean" call :clean

goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

@rem we use the newer PowerShell version if available
where /q pwsh.exe
if %ERRORLEVEL%==0 ( set _PWSH_CMD=pwsh.exe
) else ( set _PWSH_CMD=powershell.exe
)
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

@rem input parameter: %*
@rem output parameters: _BASH, _HELP, _VERBOSE
:args
set _BASH=0
set _HELP=0
set _VERBOSE=0

:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-bash" ( set _BASH=1
    ) else if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto args_loop
:args_done
call :drive_name "%_ROOT_DIR%"
if not %_EXITCODE%==0 goto :eof
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: _HELP=%_HELP% 1>&2
    echo %_DEBUG_LABEL% Variables  : _DRIVE_NAME=%_DRIVE_NAME% 1>&2
)
goto :eof

@rem input parameter: %1: path to be substituted
@rem output parameter: _DRIVE_NAME (2 characters: letter + ':')
:drive_name
set "__GIVEN_PATH=%~1"
@rem remove trailing path separator if present
if "%__GIVEN_PATH:~-1,1%"=="\" set "__GIVEN_PATH=%__GIVEN_PATH:~0,-1%"

@rem https://serverfault.com/questions/62578/how-to-get-a-list-of-drive-letters-on-a-system-through-a-windows-shell-bat-cmd
set __DRIVE_NAMES=F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:
@rem deprecated since Windows 11
@rem for /f %%i in ('wmic logicaldisk get deviceid ^| findstr :') do (
@rem     set "__DRIVE_NAMES=!__DRIVE_NAMES:%%i=!"
@rem )
@rem alternative in Windows 11
for /f "delims=" %%i in ('fsutil fsinfo drives') do (
    set "__LINE=%%i"
    set "__DRIVES=!__LINE:Drives:=!"
    set "__DRIVES=!__DRIVES:\=!"
    for %%d in (!__DRIVES!) do (
        set "__DRIVE_NAMES=!__DRIVE_NAMES:%%d=!"
    )
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% __DRIVE_NAMES=%__DRIVE_NAMES% ^(fsutil^) 1>&2
if not defined __DRIVE_NAMES (
    echo %_ERROR_LABEL% No more free drive name 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f "tokens=1,2,*" %%f in ('subst') do (
    set "__SUBST_DRIVE=%%f"
    set "__SUBST_DRIVE=!__SUBST_DRIVE:~0,2!"
    set "__SUBST_PATH=%%h"
    if /i "!__SUBST_DRIVE!"=="!__GIVEN_PATH:~0,2!" (
        set _DRIVE_NAME=!__SUBST_DRIVE:~0,2!
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        ) else if %_VERBOSE%==1 ( echo Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        )
        goto :eof
    ) else if "!__SUBST_PATH!"=="!__GIVEN_PATH!" (
        set "_DRIVE_NAME=!__SUBST_DRIVE!"
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        ) else if %_VERBOSE%==1 ( echo Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        )
        goto :eof
    )
)
for /f "tokens=1,2,*" %%i in ('subst') do (
    set __USED=%%i
    call :drive_names "!__USED:~0,2!"
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% __DRIVE_NAMES=%__DRIVE_NAMES% ^(SUBST^) 1>&2

set "_DRIVE_NAME=!__DRIVE_NAMES:~0,2!"
if /i "%_DRIVE_NAME%"=="%__GIVEN_PATH:~0,2%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% subst "%_DRIVE_NAME%" "%__GIVEN_PATH%" 1>&2
) else if %_VERBOSE%==1 ( echo Assign drive %_DRIVE_NAME% to path "%__GIVEN_PATH%" 1>&2
)
subst "%_DRIVE_NAME%" "%__GIVEN_PATH%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to assign drive %_DRIVE_NAME% to path "%__GIVEN_PATH%" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem input parameter: %1=Used drive name
@rem output parameter: __DRIVE_NAMES
:drive_names
set "__USED_NAME=%~1"
set "__DRIVE_NAMES=!__DRIVE_NAMES:%__USED_NAME%=!"
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
echo     %__BEG_O%-bash%__END%       start Git bash shell instead of Windows command prompt
echo     %__BEG_O%-debug%__END%      print commands executed by this script
echo     %__BEG_O%-verbose%__END%    print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%help%__END%        print this help message
goto :eof

@rem output parameter: _GPCP_HOME
:gpcp_net
set _GPCP_HOME=

set __GPCP_CMD=
for /f "delims=" %%f in ('where gpcp.exe 2^>NUL') do set "__GPCP_CMD=%%f"
if defined __GPCP_CMD (
    for /f "delims=" %%i in ("%__GPCP_CMD%") do set "__GPCP_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__GPCP_BIN_DIR!..") do set "_GPCP_HOME=%%f"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of gpcp executable found in PATH 1>&2
) else if defined GPCP_HOME (
    set "_GPCP_HOME=%GPCP_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GPCP_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\gpcp-NET\" ( set "_GPCP_HOME=!__PATH!\gpcp-NET"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\gpcp-NET*" 2^>NUL') do set "_GPCP_HOME=!__PATH!\%%f"
        if not defined _GPCP_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
    if defined _GPCP_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory "!_GPCP_HOME!" 1>&2
    )
)
if not exist "%_GPCP_HOME%\bin\gpcp.exe" (
    echo %_ERROR_LABEL% gpcp executable not found ^("%_GPCP_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem output parameter: _JROOT
:gpcp_jvm
set _JROOT=

set __GPCP_CMD=
for /f "delims=" %%f in ('where gpcp.bat 2^>NUL') do set "__GPCP_CMD=%%f"
if defined __GPCP_CMD (
    for /f "delims=" %%i in ("%__GPCP_CMD%") do set "__GPCP_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__GPCP_BIN_DIR!..") do set "_JROOT=%%f"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of gpcp executable found in PATH 1>&2
) else if defined _JROOT (
    set "_JROOT=%JROOT%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable JROOT 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\gpcp-JVM\" ( set "_JROOT=!__PATH!\gpcp-JVM"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\gpcp-JVM*" 2^>NUL') do set "_JROOT=!__PATH!\%%f"
        if not defined _JROOT (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\gpcp-JVM*" 2^>NUL') do set "_JROOT=!__PATH!\%%f"
        )
    )
    if defined _JROOT (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Component Pascal installation directory "!_JROOT!" 1>&2
    )
)
if not exist "%_JROOT%\bin\gpcp.bat" (
    echo %_ERROR_LABEL% gpcp executable not found ^(%_JROOT%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof


@rem input parameters:%1=required version %2=vendor 
@rem output parameter: _JAVA_HOME
:java
set _JAVA_HOME=

set __VERSION=%~1
set __VENDOR=%~2
if not defined __VENDOR ( set __JDK_NAME=jdk-%__VERSION%
) else ( set __JDK_NAME=jdk-%__VENDOR%-%__VERSION%
)
set __JAVAC_CMD=
for /f "delims=" %%f in ('where javac.exe 2^>NUL') do (
    set "__JAVAC_CMD=%%f"
    @rem we ignore Scoop managed Java installation
    if not "!__JAVAC_CMD:scoop=!"=="!__JAVAC_CMD!" set __JAVAC_CMD=
)
if defined __JAVAC_CMD (
    call :jdk_version "%__JAVAC_CMD%"
    if !_JDK_VERSION!==%__VERSION% (
        for /f "delims=" %%i in ("%__JAVAC_CMD%") do set "__BIN_DIR=%%~dpi"
        for /f "delims=" %%f in ("%__BIN_DIR%") do set "_JAVA_HOME=%%~dpf"
    ) else (
        echo %_ERROR_LABEL% Required JDK installation not found ^("%__JDK_NAME%"^) 1>&2
        set _EXITCODE=1
        goto :eof
    )
)
if defined JAVA_HOME (
    set "_JAVA_HOME=%JAVA_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable JAVA_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\%__JDK_NAME%*" 2^>NUL') do set "_JAVA_HOME=!__PATH!\%%f"
    if not defined _JAVA_HOME (
        set "__PATH=%ProgramFiles%\Java"
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\%__JDK_NAME%*" 2^>NUL') do set "_JAVA_HOME=!__PATH!\%%f"
    )
    if defined _JAVA_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Java SDK installation directory "!_JAVA_HOME!" 1>&2
    )
)
if not exist "%_JAVA_HOME%\bin\javac.exe" (
    echo %_ERROR_LABEL% Executable javac.exe not found ^("%_JAVA_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
call :jdk_version "%_JAVA_HOME%\bin\javac.exe"
set "_JAVA!_JDK_VERSION!_HOME=%_JAVA_HOME%"
goto :eof

@rem input parameter: %1=javac file path
@rem output parameter: _JDK_VERSION
:jdk_version
set "__JAVAC_CMD=%~1"
if not exist "%__JAVAC_CMD%" (
    echo %_ERROR_LABEL% Command javac.exe not found ^("%__JAVAC_CMD%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __JAVAC_VERSION=
for /f "usebackq tokens=1,*" %%i in (`"%__JAVAC_CMD%" -version 2^>^&1`) do set "__JAVAC_VERSION=%%j"
set "__PREFIX=%__JAVAC_VERSION:~0,2%"
@rem either 1.7, 1.8 or 11..18
if "%__PREFIX%"=="1." ( set _JDK_VERSION=%__JAVAC_VERSION:~2,1%
) else ( set _JDK_VERSION=%__PREFIX%
)
goto :eof

@rem output parameters: _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f "delims=" %%f in ('where git.exe 2^>NUL') do set "__GIT_CMD=%%f"
if defined __GIT_CMD (
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    for /f "delims=" %%i in ("%__GIT_CMD%") do set "__GIT_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__GIT_BIN_DIR!..") do set "_GIT_HOME=%%f"
    @rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for /f "delims=" %%f in ("!_GIT_HOME!\..") do set "_GIT_HOME=%%f"
    )
    @rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set "_GIT_HOME=!__PATH!\Git"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
    if defined _GIT_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory "!_GIT_HOME!" 1>&2
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^(%_GIT_HOME%^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

@rem output parameters: _MSYS_HOME, _MSYS_PATH
:msys
set _MSYS_HOME=
set _MSYS_PATH=

set __MAKE_CMD=
for /f "delims=" %%f in ('where make.exe 2^>NUL') do set "__MAKE_CMD=%%f"
if defined __MAKE_CMD (
    for /f "delims=" %%i in ("%__MAKE_CMD%") do set "__MAKE_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__MAKE_BIN_DIR!\.") do set "_MSYS_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of GNU Make executable found in PATH 1>&2
    @rem keep _MSYS_PATH undefined since executable already in path
    goto :eof
) else if defined MSYS_HOME (
    set "_MSYS_HOME=%MSYS_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable MSYS_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    if not defined _MSYS_HOME (
        set "__PATH=ProgramFiles%"
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    )
)
if not exist "%_MSYS_HOME%\usr\bin\make.exe" (
    echo %_ERROR_LABEL% GNU Make executable not found ^("%_MSYS_HOME%"^) 1>&2
    set _MSYS_HOME=
    set _EXITCODE=1
    goto :eof
)
@rem 1st path -> (make.exe, python.exe), 2nd path -> gcc.exe
set "_MSYS_PATH=;%_MSYS_HOME%\usr\bin;%_MSYS_HOME%\mingw64\bin"
goto :eof

:clean
for %%f in ("%~dp0") do set __ROOT_DIR=%%~sf
for /f "delims=" %%i in ('dir /ad /b "%__ROOT_DIR%\" 2^>NUL') do (
    for /f "delims=" %%j in ('dir /ad /b "%%i\target\scala-*" 2^>NUL') do (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% rmdir /s /q %__ROOT_DIR%%%i\target\%%j\classes 1^>NUL 2^>^&1 1>&2
        rmdir /s /q "%__ROOT_DIR%%%i\target\%%j\classes" 1>NUL 2>&1
    )
)
goto :eof

:print_env
set __VERBOSE=%1
set __VERSIONS_LINE1=
set __VERSIONS_LINE2=
set __WHERE_ARGS=
setlocal enabledelayedexpansion

where /q "%JAVA_HOME%\bin:java.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%JAVA_HOME%\bin\java.exe" -version 2^>^&1 ^| findstr version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% java %%~k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%JAVA_HOME%\bin:java.exe"
)
where /q "%GPCP_HOME%\bin:gpcp.exe"
if %ERRORLEVEL%==0 (
   for /f "tokens=1-3,4,*" %%i in ('call "%GPCP_HOME%\bin\gpcp.exe" /version ^| findstr version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% gpcp %%l,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GPCP_HOME%\bin:gpcp.exe"
)
where /q "%JROOT%\jars:j2cps.jar"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('call "%JAVA_HOME%\bin\java.exe" -jar "%JROOT%\jars\j2cps.jar" -version 2^>NUL') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% j2cps %%~k,"
)
where /q "%MSYS_HOME%\usr\bin:make.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('"%MSYS_HOME%\usr\bin\make.exe" --version 2^>^&1 ^| findstr Make') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% make %%k,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSYS_HOME%\usr\bin:make.exe"
) 
where /q "%GIT_HOME%\bin:git.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%GIT_HOME%\bin\git.exe" --version') do (
        for /f "delims=. tokens=1,2,3,*" %%a in ("%%k") do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% git %%a.%%b.%%c,"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:git.exe"
)
where /q "%GIT_HOME%\usr\bin:diff.exe"
if %ERRORLEVEL%==0 (
   for /f "tokens=1-3,*" %%i in ('"%GIT_HOME%\usr\bin\diff.exe" --version ^| findstr diff') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% diff %%l,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\usr\bin:diff.exe"
)
where /q "%GIT_HOME%\bin:bash.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('"%GIT_HOME%\bin\bash.exe" --version ^| findstr bash') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% bash %%l"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:bash.exe"
)
echo Tool versions:
echo   %__VERSIONS_LINE1%
echo   %__VERSIONS_LINE2%
if %__VERBOSE%==1 (
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do (
        set "__LINE=%%p"
        echo    !__LINE:%USERPROFILE%=%%USERPROFILE%%! 1>&2
    )
    echo Environment variables: 1>&2
    if defined CROOT echo    "CROOT=%CROOT%" 1>&2
    if defined GIT_HOME echo    "GIT_HOME=%GIT_HOME%" 1>&2
    if defined GPCP_HOME echo    "GPCP_HOME=%GPCP_HOME%" 1>&2
    if defined JAVA_HOME echo    "JAVA_HOME=%JAVA_HOME%" 1>&2
    if defined JROOT echo    "JROOT=%JROOT%" 1>&2
    if defined MSYS_HOME echo    "MSYS_HOME=%MSYS_HOME%" 1>&2
    echo Path associations: 1>&2
    for /f "delims=" %%i in ('subst') do (
        set "__LINE=%%i"
        echo    !__LINE:%USERPROFILE%=%%USERPROFILE%%! 1>&2
    )
)
endlocal
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
endlocal & (
    if %_EXITCODE%==0 (
        if not defined CROOT set "CROOT=%_GPCP_HOME%"
        if not defined GIT_HOME set "GIT_HOME=%_GIT_HOME%"
        if not defined GPCP_HOME set "GPCP_HOME=%_GPCP_HOME%"
        if not defined JAVA_HOME set "JAVA_HOME=%_JAVA_HOME%"
        if not defined JROOT set "JROOT=%_JROOT%"
        if not defined MSYS_HOME set "MSYS_HOME=%_MSYS_HOME%"
        set "PATH=%PATH%%_MSYS_PATH%%_GIT_PATH%;%~dp0bin"
        call :print_env %_VERBOSE%
        if not "%CD:~0,2%"=="%_DRIVE_NAME%" (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% cd /d %_DRIVE_NAME% 1>&2
            cd /d %_DRIVE_NAME%
        )
        if %_BASH%==1 (
            @rem see https://conemu.github.io/en/GitForWindows.html
            if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_HOME%\usr\bin\bash.exe --login 1>&2
            cmd.exe /c "%_GIT_HOME%\usr\bin\bash.exe --login"
        )
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
