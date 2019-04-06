@ECHO OFF
CD /D "%~dp0"

SET "CurrentDir=%~dp0"
SET "ToolsDir=%CurrentDir%\_Tools"
SET "InputApk=%~1"
SET "OutputJar=%~dpn1.jar"

SET "PATH=%PATH%;%ToolsDir%\dex2jar"

IF NOT EXIST "%InputApk%" (
    ECHO Cannot find %InputApk%
    GOTO :EXIT
)

IF NOT EXIST "%ToolsDir%" (
    ECHO Cannot find "%ToolsDir%"
    GOTO :EXIT
)

ECHO Converting
CALL "%ToolsDir%\dex2jar\d2j-dex2jar" -f "%InputApk%" -o "%OutputJar%"
ECHO %InputApk% is converted to %OutputJar%

:EXIT
PAUSE