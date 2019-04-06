@ECHO OFF
CD /D "%~dp0"

SET "CurrentDir=%~dp0"
SET "ToolsDir=%CurrentDir%\_Tools"
SET "InputZip=%~1"
SET "OutputZip=%~dpn1_signed%~x1"

SET "PATH=%PATH%;%ToolsDir%\signapk"

IF NOT EXIST "%InputZip%" (
    ECHO Cannot find "%InputZip%"
    GOTO :EXIT
)

IF NOT EXIST "%ToolsDir%" (
    ECHO Cannot find "%ToolsDir%"
    GOTO :EXIT
)
IF EXIST "%OutputZip%" ( DEL /F /Q "%OutputZip%" )

ECHO Ready to sign "%InputZip%"
java -jar "%ToolsDir%\signapk\signapk.jar" "%ToolsDir%\signapk\testkey.x509.pem" "%ToolsDir%\signapk\testkey.pk8" "%InputZip%" "%OutputZip%"
ECHO "%OutputZip%" is signed
CD "%CurrentDir%"

:EXIT
PAUSE