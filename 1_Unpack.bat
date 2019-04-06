@ECHO OFF
CD /D "%~dp0"

SET "CurrentDir=%~dp0"
SET "ToolsDir=%CurrentDir%\_Tools"
SET "BackupDir=%CurrentDir%\_ApkBackup"
SET "UnpackDir=%CurrentDir%\1_Unpacked"

SET "PATH=%PATH%;%ToolsDir%\apktool;%ToolsDir%\dex2jar"

IF NOT EXIST *.apk (
    ECHO Cannot find any apk file
    GOTO :EXIT
)

IF NOT EXIST "%ToolsDir%" (
    ECHO Cannot find "%ToolsDir%"
    GOTO :EXIT
)
IF NOT EXIST "%BackupDir%" ( MD "%BackupDir%" )
IF NOT EXIST "%UnpackDir%" ( MD "%UnpackDir%" )


ECHO Analyzing
FOR %%i IN (*.apk) DO (
    ECHO "%%i" is currently unpacking
    CALL java -jar "%ToolsDir%\apktool\apktool.jar" d -f -o "_%%i" "%%i"
    MOVE  "_%%i" "%UnpackDir%\%%i"
    MOVE "%%i" "%BackupDir%"
    ECHO "%%i" is unpacked
    
    IF "%~1" NEQ "" (
        CALL "%ToolsDir%\dex2jar\d2j-dex2jar" -f "%BackupDir%\%%i" -o "%UnpackDir%\%%i.jar"
        CALL "%ToolsDir%\jd-gui\jd-gui" "%UnpackDir%\%%i.jar"
    )
)
ECHO All apk files are unpacked


:EXIT
PAUSE