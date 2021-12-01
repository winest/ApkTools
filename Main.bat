@set @_PackJsInBatByWinest=0 /*
@ECHO OFF
CD /D "%~dp0"
CSCRIPT "%~0" //D //Nologo //E:JScript %1 %2 %3 %4 %5 %6 %7 %8 %9
IF %ERRORLEVEL% LSS 0 ( ECHO Failed. Error code is %ERRORLEVEL% )
PAUSE
EXIT /B
*/

var WshFileSystem = new ActiveXObject( "Scripting.FileSystemObject" );
var WshShell = WScript.CreateObject( "WScript.Shell" );
function LoadJs( aJsPath )
{
    var file = WshFileSystem.OpenTextFile( aJsPath , 1 );
    var strContent = file.ReadAll();
    file.Close();
    return strContent;
}
eval( LoadJs( "..\\..\\..\\_3rdParty\\CWUtils\\JScript\\Windows\\CWGeneralUtils.js" ) );
eval( LoadJs( "..\\..\\..\\_3rdParty\\CWUtils\\JScript\\Windows\\CWFile.js" ) );
eval( LoadJs( "..\\..\\..\\_3rdParty\\CWUtils\\JScript\\Windows\\CWStd.js" ) );
eval( LoadJs( "..\\..\\..\\_3rdParty\\CWUtils\\JScript\\Windows\\CWShell.js" ) );
eval( LoadJs( "ShowApk.js" ) );
eval( LoadJs( "RenameApk.js" ) );



var strLogFolder = WshShell.CurrentDirectory + "\\_Log";
CleanLogFolder();

for ( ;; )
{
    WScript.Echo( "\n\n\n========== Common Intermediate Language Tools by winest ==========\n" );
    WScript.Echo( "What would you like to do?\n" +
                  "1. Generate apk list\n" +
                  "2. Rename apk to original name with version\n" +
                  "3. Rename apk to original name for Android 4.4 or lower\n" +
                  "4. Rename apk to original name for Android 5.0 or upper\n" +
                  "5. Sign apk\n" +
                  "6. Unpack apk\n" +
                  "7. Repack apk\n" +
                  "8. Zip-Align apk\n" +
                  "9. Leave" );
    var strChoice = WScript.StdIn.ReadLine();
    switch ( strChoice )
    {
        case "1" :
        {
            var strInFolderPath = CWUtils.SelectFolder( "Please enter the input folder path:" );

            if ( true == TraverseAndShowApk( strInFolderPath , strLogFolder ) )
            {
                WScript.Echo( "TraverseAndShowApk() succeed." );
            }
            else
            {
                WScript.Echo( "TraverseAndShowApk() failed" );
            }
            break;
        }
        case "2" :
        {
            var strInFolderPath = CWUtils.SelectFolder( "Please enter the input folder path:" );
            var strOutFolderPath = CWUtils.SelectFolder( "Please enter the output folder path:" , false );
            if ( false == WshFileSystem.FolderExists(strOutFolderPath) )
            {
                WshFileSystem.CreateFolder( strOutFolderPath );
            }

            if ( true == TraverseAndRenameApkToVersion( strInFolderPath , strOutFolderPath , strLogFolder ) )
            {
                WScript.Echo( "RenameApkToVersion() succeed" );
            }
            else
            {
                WScript.Echo( "RenameApkToVersion() failed" );
            }
            break;
        }
        case "3" :
        {
            var strInFolderPath = CWUtils.SelectFolder( "Please enter the input folder path:" , true );
            var strOutFolderPath = CWUtils.SelectFolder( "Please enter the output folder path:" , false );
            if ( false == WshFileSystem.FolderExists(strOutFolderPath) )
            {
                WshFileSystem.CreateFolder( strOutFolderPath );
            }

            if ( true == TraverseAndRenameApkToRom44( strInFolderPath , strOutFolderPath , strLogFolder ) )
            {
                WScript.Echo( "RenameApkToRom44() succeed" );
            }
            else
            {
                WScript.Echo( "RenameApkToRom44() failed" );
            }
            break;
        }    
        case "4" :
        {
            var strInFolderPath = CWUtils.SelectFolder( "Please enter the input folder path:" , true );
            var strOutFolderPath = CWUtils.SelectFolder( "Please enter the output folder path:" , false );
            if ( false == WshFileSystem.FolderExists(strOutFolderPath) )
            {
                WshFileSystem.CreateFolder( strOutFolderPath );
            }

            if ( true == TraverseAndRenameApkToRom50( strInFolderPath , strOutFolderPath , strLogFolder ) )
            {
                WScript.Echo( "RenameApkToRom50() succeed" );
            }
            else
            {
                WScript.Echo( "RenameApkToRom50() failed" );
            }
            break;
        }        
        case "5" :
        {
            var strInPath = CWUtils.SelectFile( "Please enter the apk/zip file path:" );
            var strOutPath = WshFileSystem.GetParentFolderName( strInPath ) + "\\" + WshFileSystem.GetBaseName( strInPath ) + "_signed." + WshFileSystem.GetExtensionName( strInPath );
            var aryOutput = [];
            var execObj = CWUtils.Exec( "java --version" , true , aryOutput );
            //java 11.0.2 2019-01-15 LTS
            //java version "1.8.0_251"
            //openjdk 11 2018-09-25
            var regex = /(java|openjdk) (version 1\.)?([0-9]+)[ .].+/;
            var match = regex.exec( aryOutput[0] );
            var uJavaVer = parseInt( match[3] );
            
            var cmd = "";
            if ( uJavaVer >= 9 )
            {
                cmd = "java -jar " +
                      "\"" + WshShell.CurrentDirectory + "\\_Tools\\\apksigner\\\apksigner.jar\" " + 
                      "sign " +
                      "--cert \"" + WshShell.CurrentDirectory + "\\_Tools\\apksigner\\testkey.x509.pem\" " +
                      "--key \"" + WshShell.CurrentDirectory + "\\_Tools\\apksigner\\testkey.pk8\" " +
                      "--in \"" + strInPath + "\" " +
                      "--out \"" + strOutPath + "\"";
            }
            else
            {
                cmd = "java -jar " +
                      "\"" + WshShell.CurrentDirectory + "\\_Tools\\signapk\\signapk.jar\" " + 
                      "\"" + WshShell.CurrentDirectory + "\\_Tools\\signapk\\testkey.x509.pem\" " +
                      "\"" + WshShell.CurrentDirectory + "\\_Tools\\signapk\\testkey.pk8\" " +
                      "\"" + strInPath + "\" " +
                      "\"" + strOutPath + "\"";
            }
            
            WScript.Echo( cmd );
            var execObj = CWUtils.Exec( cmd , true , aryOutput );
            if ( 0 == execObj.ExitCode )
            {
                WScript.Echo( "Sign succeed" );
            }
            else
            {
                WScript.Echo( "Sign failed with code " + execObj.ExitCode );
                for (var i = 0; i < aryOutput.length; ++i)
                {
                    WScript.Echo( aryOutput[i] );
                }
            }
            break;
        }
        case "6" :
        {
            var strInPath = CWUtils.SelectFile( "Please enter the apk/zip file path:" );
            var strOutPath = WshFileSystem.GetParentFolderName( strInPath ) + "\\" + WshFileSystem.GetBaseName( strInPath );
            var execObj = CWUtils.Exec( "\"" + WshShell.CurrentDirectory + "\\_Tools\\apktool\\apktool.bat\" " + 
                                        "d -f " +
                                        "-o \"" + strOutPath + "\" " +
                                        "\"" + strInPath + "\"" , true );
            if ( 0 == execObj.ExitCode )
            {
                WScript.Echo( "Unpack succeed" );
                WshFileSystem.CopyFile( strInPath , WshShell.CurrentDirectory + "\\_ApkBackup\\" + WshFileSystem.GetFileName( strInPath ) , true );
            }
            else
            {
                WScript.Echo( "Unpack failed with code " + execObj.ExitCode );
            }
            break;
        }
        case "7" :
        {
            var strInPath = CWUtils.SelectFolder( "Please enter the source folder path:" );
            var strOutPath = WshFileSystem.GetParentFolderName( strInPath ) + "\\" + WshFileSystem.GetFileName( strInPath ) + "_repacked.apk";
            var execObj = CWUtils.Exec( "\"" + WshShell.CurrentDirectory + "\\_Tools\\apktool\\apktool.bat\" " + 
                                        "b " +
                                        "-o \"" + strOutPath + "\" " +
                                        "\"" + strInPath + "\"" , true );
            if ( 0 == execObj.ExitCode )
            {
                WScript.Echo( "Repack succeed" );
            }
            else
            {
                WScript.Echo( "Repack failed with code " + execObj.ExitCode );
            }
            break;
        }
        case "8" :
        {
            var strInPath = CWUtils.SelectFile( "Please enter the apk/zip file path:" );
            var strOutPath = WshFileSystem.GetParentFolderName( strInPath ) + "\\" + WshFileSystem.GetBaseName( strInPath ) + "_aligned." + WshFileSystem.GetExtensionName( strInPath );
            
            var cmd = "\"" + WshShell.CurrentDirectory + "\\_Tools\\zipalign\\zipalign.exe\" " + 
                      "-p -v 4 " +
                      "\"" + strInPath + "\" " +
                      "\"" + strOutPath + "\"";
            WScript.Echo( cmd );
            var execObj = CWUtils.Exec( cmd , true , aryOutput );
            if ( 0 == execObj.ExitCode )
            {
                WScript.Echo( "Zip-Align succeed" );
            }
            else
            {
                WScript.Echo( "Zip-Align failed with code " + execObj.ExitCode );
                for (var i = 0; i < aryOutput.length; ++i)
                {
                    WScript.Echo( aryOutput[i] );
                }
            }
            break;
        }
        case "9" :
        {
            if ( true == CWUtils.SelectYesNo( "Are you going to leave? (y/n)" ) )
            {
                WScript.Echo( "Successfully End" );
                WScript.Quit( 0 );
            }
            break;
        }
        default :
        {
            WScript.Echo( "Unknown choice: " + strChoice );
            break;
        }
    }
}


function CleanLogFolder()
{
    if ( WshFileSystem.FolderExists(strLogFolder) )
    {
        var folder = WshFileSystem.GetFolder( strLogFolder );

        var enumFolder = new Enumerator( folder.SubFolders );
        for ( ; ! enumFolder.atEnd() ; enumFolder.moveNext() )
        {
            WshFileSystem.DeleteFolder( enumFolder.item().Path , true );
        }
        var enumFile = new Enumerator( folder.Files );
        for ( ; ! enumFile.atEnd() ; enumFile.moveNext() )
        {
            WshFileSystem.DeleteFile( enumFile.item().Path , true );
        }
    }
}
