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



function TraverseAndLogApk( aInFolder , aLogFolder )
{
    var folder = WshFileSystem.GetFolder( aInFolder );
    var enumFolder = new Enumerator( folder.SubFolders );
    for ( ; ! enumFolder.atEnd() ; enumFolder.moveNext() )
    {
        if ( false == TraverseAndLogApk( enumFolder.item().Path , aLogFolder ) )
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
                CWUtils.DbgMsg( "ERRO" , "LogApk" , "GetPackageInfo() failed for " + enumFile.item().Path , aLogFolder );
                return false;
            }
            var readableName = info.Name + "-ver" + info.Version + ".apk";
            CWUtils.DbgMsg( "INFO" , "LogApk" , enumFile.item().Path + " => " + readableName , aLogFolder );
        }
    }
    return true;
}






function TraverseAndRenameApkToRom44( aInFolder , aOutFolder , aLogFolder )
{
    var folder = WshFileSystem.GetFolder( aInFolder );
    var enumFolder = new Enumerator( folder.SubFolders );
    for ( ; ! enumFolder.atEnd() ; enumFolder.moveNext() )
    {
        if ( false == TraverseAndRenameApkToRom44( enumFolder.item().Path , aOutFolder , aLogFolder ) )
        {
            return false;
        }
    }

    CWUtils.DbgMsg( "VERB" , "RenameApkToRom44" , "Checking apk files in \"" + aInFolder + "\"" , aLogFolder );
    var enumFile = new Enumerator( folder.Files );
    for ( ; ! enumFile.atEnd() ; enumFile.moveNext() )
    {
        if ( enumFile.item().Name.match(/.+\.apk/) )
        {
            CWUtils.DbgMsg( "VERB" , "RenameApkToRom44" , "Renaming " + enumFile.item().Name , aLogFolder );
            var info = new CPackageInfo();
            if ( false == GetPackageInfo( enumFile.item().Path , info ) )
            {
                CWUtils.DbgMsg( "ERRO" , "RenameApkToRom44" , "GetPackageInfo() failed for " + enumFile.item().Path , aLogFolder );
                return false;
            }
            var dstName = info.Name + "-1.apk";
            var dstPath = aOutFolder + "\\" + dstName;
            CWUtils.DbgMsg( "INFO" , "RenameApkToRom44" , enumFile.item().Name + " => " + dstName , aLogFolder );
            WshFileSystem.CopyFile( enumFile.item().Path , dstPath , true )
        }
    }

    return true;
}

function TraverseAndRenameApkToRom50( aInFolder , aOutFolder , aLogFolder )
{
    if ( aInFolder == aOutFolder )
    {
        CWUtils.DbgMsg( "WARN" , "RenameApkToRom50" , "Skip aOutFolder" , aLogFolder );
        return false;
    }

    //Depth 1: wrap apk at this depth directly
    var folder = WshFileSystem.GetFolder( aInFolder );
    var enumFile = new Enumerator( folder.Files );
    for ( ; ! enumFile.atEnd() ; enumFile.moveNext() )
    {
        if ( enumFile.item().Name.match(/.+\.apk/) )
        {
            var info = new CPackageInfo();
            if ( false == GetPackageInfo( enumFile.item().Path , info ) )
            {
                CWUtils.DbgMsg( "ERRO" , "RenameApkToRom50" , "GetPackageInfo() failed for " + enumFile.item().Path , aLogFolder );
                return false;
            }
            var strPkgName = info.Name + "-1";
            var dstFolderPath = aOutFolder + "\\" + strPkgName;
            CWUtils.DbgMsg( "INFO" , "RenameApkToRom50" , enumFile.item().Name + " => " + strPkgName + "\\base.apk" , aLogFolder );
            WshFileSystem.CreateFolder( dstFolderPath );
            WshFileSystem.CopyFile( enumFile.item().Path , dstFolderPath + "\\base.apk" , true )
        }
    }

    //Depth 2: Assume there should exist an apk file inside, then copy all files inside to the output folder
    var enumSubFolder = new Enumerator( folder.SubFolders );
    for ( ; ! enumSubFolder.atEnd() ; enumSubFolder.moveNext() )
    {
        CWUtils.DbgMsg( "VERB" , "RenameApkToRom50" , "Checking apk files in \"" + enumSubFolder.item().Path + "\"" , aLogFolder );
        
        //Find the apk name at first to determine the final folder's name
        var strPkgName = "";
        var enumSubFile = new Enumerator( enumSubFolder.item().Files );
        for ( ; ! enumSubFile.atEnd() ; enumSubFile.moveNext() )
        {
            if ( enumSubFile.item().Name.match(/.+\.apk/) )
            {
                var info = new CPackageInfo();
                if ( false == GetPackageInfo( enumSubFile.item().Path , info ) )
                {
                    CWUtils.DbgMsg( "ERRO" , "RenameApkToRom50" , "GetPackageInfo() failed for " + enumFile.item().Path , aLogFolder );
                    return false;
                }
                strPkgName = info.Name + "-1";
                CWUtils.DbgMsg( "INFO" , "RenameApkToRom50" , enumSubFile.item().Name + " => " + "base.apk" , aLogFolder );
                WshFileSystem.MoveFile( enumSubFile.item().Path , enumSubFolder.item().Path + "\\base.apk"  );
            }
        }

        //Copy all folders and files
        if ( 0 < strPkgName.length )
        {
            CWUtils.DbgMsg( "INFO" , "RenameApkToRom50" , enumSubFolder.item().Name + " => " + strPkgName , aLogFolder );
            WshFileSystem.CopyFolder( enumSubFolder.item().Path , aOutFolder + "\\" + strPkgName , true );
        }
    }
    return true;
}

