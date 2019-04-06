@ECHO OFF
CD /D "%~dp0"

IF "%~1" == "" ( 
    ECHO "Usage: %~xn0 <JavaClassDir>"
    GOTO :EXIT
)

SET "TmpDir=_Tmp"
SET "JavaClassDir=%~1"
SET "SmaliDir=%~1_Smali"

IF NOT EXIST "%JavaClassDir%" ( 
    ECHO "%1 is not found"
    GOTO :EXIT
)

IF NOT EXIST "%TmpDir%" (
    MKDIR "%TmpDir%"
)

ECHO JavaClassDir=%JavaClassDir%
ECHO SmaliDir=%SmaliDir%


SET "CurrentDir=%~dp0"
SET "ToolsDir=%CurrentDir%\_Tools"
SET "PATH=%PATH%;%ToolsDir%\dx;%ToolsDir%\baksmali"



ECHO "Compacting *.class to %~nx1_classes.dex"
CALL dx --dex --output="%TmpDir%\%~nx1_classes.dex" "%JavaClassDir%"

ECHO Converting "%TmpDir%\%~nx1_classes.dex" and save to "%SmaliDir%"
CALL java -jar "%ToolsDir%\baksmali\baksmali.jar" -l -o "%SmaliDir%" "%TmpDir%\%~nx1_classes.dex"

IF EXIST "%TmpDir%" (
    DEL /F /S /Q "%TmpDir%" > nul
    RMDIR /S /Q "%TmpDir%"
)
ECHO End of the program

:EXIT
PAUSE