@echo off
setlocal
set BASENAME=jd-gui
chcp 65001 2>nul >nul

set java_exe=java.exe

if defined JAVA_HOME (
set java_exe="%JAVA_HOME%\bin\java.exe"
)

rem Find the highest version .jar available in the same directory as the script
setlocal EnableDelayedExpansion
pushd "%~dp0"
if exist jd-gui.jar (
    set BASENAME=jd-gui
    goto skipversioned
)
set max=0
for /f "tokens=1* delims=-_.0" %%A in ('dir /b /a-d %BASENAME%*.jar') do if %%~B gtr !max! set max=%%~nB
:skipversioned
popd
setlocal DisableDelayedExpansion

:load
%java_exe% -jar -Duser.language=en -Dfile.encoding=UTF8 "%~dp0%BASENAME%%max%.jar" %*

rem Pause when ran non interactively
for /f "tokens=2" %%# in ("%cmdcmdline%") do if /i "%%#" equ "/c" pause