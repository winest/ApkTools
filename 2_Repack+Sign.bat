@ECHO OFF
CD /D "%~dp0"

SET "CurrentDir=%~dp0"
SET "ToolsDir=%CurrentDir%\_Tools"
SET "UnpackDir=%CurrentDir%\1_Unpacked"
SET "RepackDir=%CurrentDir%\2_Repacked"

SET "PATH=%PATH%;%ToolsDir%\apktool;%ToolsDir%\aapt;%ToolsDir%\signapk"

IF NOT EXIST "%UnpackDir%" (
    ECHO Cannot find "%UnpackDir%"
    GOTO :EXIT
)

IF NOT EXIST "%ToolsDir%" (
    ECHO Cannot find "%ToolsDir%"
    GOTO :EXIT
)
IF NOT EXIST "%RepackDir%" ( MD "%RepackDir%" )

CD "%UnpackDir%"
ECHO Analyzing
FOR /d %%i IN (*) DO (
    ECHO "%%i" is currently repacking
    java -jar "%ToolsDir%\apktool\apktool.jar" b "%UnpackDir%\%%i"
    ECHO "%%i" is ready to sign
    java -jar "%ToolsDir%\signapk\signapk.jar" "%ToolsDir%\signapk\testkey.x509.pem" "%ToolsDir%\signapk\testkey.pk8" "%UnpackDir%\%%i\dist\%%i" "_%%i"
    MOVE "_%%i" "%RepackDir%\New_%%i"
    ECHO "%%i" is repacked and signed
)
CD "%CurrentDir%"

:EXIT
PAUSE