function CPackageInfo()
{
    this.Name;
    this.Version;
}

function GetPackageInfo( aFilePath , aPackageInfo )
{
    //Example: package: name='com.facebook.katana' versionCode='3584822' versionName='14.0.0.17.13'
    var bRet = false;
    var strTmpPath = aFilePath + ".tmp";
    var execObj = WshShell.Exec( "aapt.exe dump badging \"" + aFilePath + "\"" );
    var strOutput = execObj.StdOut.ReadLine();
    if ( 0 < strOutput.length )
    {
        var rePtn = /package: name='([^']+)' .*versionName='(.+?)'/;
        var aryInfo = rePtn.exec( strOutput );
        if ( null != aryInfo )
        {
            //WScript.Echo( "Package: " + aryInfo[1] );
            //WScript.Echo( "Version: " + aryInfo[2] );
            aPackageInfo.Name = aryInfo[1];
            aPackageInfo.Version = aryInfo[2];
            bRet = true;
        }
    }
    execObj.StdOut.Close();
    execObj.Terminate()
    return bRet;
}



function TraverseAndShowApk( aInFolder , aLogFolder )
{
    var folder = WshFileSystem.GetFolder( aInFolder );
    var enumFolder = new Enumerator( folder.SubFolders );
    for ( ; ! enumFolder.atEnd() ; enumFolder.moveNext() )
    {
        if ( false == TraverseAndShowApk( enumFolder.item().Path , aLogFolder ) )
        {
            return false;
        }
    }

    var enumFile = new Enumerator( folder.Files );
    for ( ; ! enumFile.atEnd() ; enumFile.moveNext() )
    {
        if ( enumFile.item().Name.match(/.+\.apk/) )
        {
            var info = new CPackageInfo();
            if ( false == GetPackageInfo( enumFile.item().Path , info ) )
            {
                CWUtils.DbgMsg( "ERRO" , "ShowApk" , "GetPackageInfo() failed for " + enumFile.item().Path , aLogFolder );
                return false;
            }
            var readableName = info.Name + "-ver" + info.Version + ".apk";
            CWUtils.DbgMsg( "INFO" , "ShowApk" , enumFile.item().Path + " => " + readableName , aLogFolder );
        }
    }
    return true;
}
