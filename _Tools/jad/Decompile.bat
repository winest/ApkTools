@set @_ThisWillNeverBeUsed=0 /*
@ECHO OFF
CD /D "%~dp0"
CSCRIPT "%~0" //Nologo //E:JScript %1 %2 %3 %4 %5 %6 %7 %8 %9
IF %ERRORLEVEL% LSS 0 ( ECHO Failed. Error code is %ERRORLEVEL% )
PAUSE
EXIT /B
*/

if ( 0 == WScript.Arguments.Count() )
{
    WScript.Echo( "Please input folder path" );
    WScript.Quit( -1 );
}

var WshFileSystem = new ActiveXObject( "Scripting.FileSystemObject" );
var WshShell = WScript.CreateObject( "WScript.Shell" );
for ( var i = 0 ; i < WScript.Arguments.Count() ; i++ )
{
    var strOutputDir = WshShell.CurrentDirectory + "\\Output_" + WshFileSystem.GetBaseName( WScript.Arguments.Item(i) );
    if ( ! WshFileSystem.FolderExists( strOutputDir ) )
    {
        WshFileSystem.CreateFolder( strOutputDir );
    }
    DecompileFolder( WScript.Arguments.Item(i) , strOutputDir );
}



WScript.Echo( "Successfully End" );
WScript.Quit( 0 );


function DecompileFolder( aInputDir , aOutputDir )
{
    var folder = WshFileSystem.GetFolder( aInputDir );
    var enumFolder = new Enumerator( folder.SubFolders );
    for ( ; ! enumFolder.atEnd() ; enumFolder.moveNext() )
    {
        //Use enumFolder.item().Path or enumFolder.item().Name to get fullpath or directory name
        //Use enumFolder.item().Size to get total size under this directory
        var strOutputDir = aOutputDir + "\\" + enumFolder.item().Name;
        if ( ! WshFileSystem.FolderExists( strOutputDir ) )
        {
            WshFileSystem.CreateFolder( strOutputDir );
        }
        DecompileFolder( enumFolder.item().Path , strOutputDir );
    }
    var enumFile = new Enumerator( folder.Files );
    for ( ; ! enumFile.atEnd() ; enumFile.moveNext() )
    {
        //Use enumFile.item().Path or enumFolder.item().Name to get fullpath or file name
        //Use enumFolder.item().Size to get size of this file
        if ( ".class" == enumFile.item().Name.substr( enumFile.item().Name.lastIndexOf('.') ) )
        {
            WScript.Echo( "jad.exe -f -lnc -s java -d \"" + aOutputDir + "\" \"" + enumFile.item().Path + "\"" );
            Exec( "jad.exe -f -lnc -s java -d \"" + aOutputDir + "\" \"" + enumFile.item().Path + "\"" );
        }
    }
}


function Exec( aCmd )
{
    //Return a WshScriptExec object, refer to http://msdn.microsoft.com/en-us/library/2f38xsxe(v=vs.84).aspx
    var execObj = WshShell.Exec( aCmd );
    while ( 0 == execObj.Status )   //0 for running, 1 for completed
    {
        WScript.Sleep( 100 );
    }
    return execObj.ExitCode;
}