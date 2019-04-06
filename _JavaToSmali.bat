@ECHO OFF
CD /D "%~dp0"

IF "%~1" == "" ( 
    ECHO "Usage: %~xn0 <JavaSrcDir>"
    GOTO :EXIT
)

SET "TmpDir=_Tmp"
SET "JavaSrcDir=%~1"
SET "JavaClassDir=%TmpDir%\%~nx1_Class"
SET "SmaliDir=%~1_Smali"

IF NOT EXIST "%JavaSrcDir%" ( 
    ECHO "%1 is not found"
    GOTO :EXIT
)

IF NOT EXIST "%TmpDir%" (
    MKDIR "%TmpDir%"
)
IF NOT EXIST "%JavaClassDir%" (
    MKDIR "%JavaClassDir%"
)

ECHO JavaSrcDir=%JavaSrcDir%
ECHO JavaClassDir=%JavaClassDir%
ECHO SmaliDir=%SmaliDir%


SET "CurrentDir=%~dp0"
SET "ToolsDir=%CurrentDir%\_Tools"
SET "PATH=%PATH%;%ToolsDir%\dx;%ToolsDir%\baksmali"





ECHO Compiling java
DIR /S /B "%JavaSrcDir%\*.java" > "%TmpDir%\%~nx1_list.txt"
CALL javac @"%TmpDir%\%~nx1_list.txt" -d "%JavaClassDir%"

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