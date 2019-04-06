@echo off

echo ***********************************
echo 將自己寫的class混編(注入)到需要反編譯的apk(mix/inject classes2apk)
echo ==================================
echo v1.0 20121024 by Sun https://onekey-decompile-apk.googlecode.com/svn/trunk

echo !
echo 功能
echo --------
echo 1. 將自己寫的class檔案變成android的dex格式
echo 2. 將dex格式反編譯為smali代碼
echo 3. 合併這些smali代碼到apk反編譯的smali目錄

echo ?
echo 使用方法
echo --------
echo _inject_classes {class目錄} {apk反編譯的smali目錄}
echo 例如: _inject_classes D:\TestSmaliInject\build\classes D:\TestSmali\smali
echo ***********************************


rem classes目錄
set injectClassesDir=%1
set injectApk=%injectClassesDir%\..\inject.apk
set injectOutput=%injectClassesDir%\..\injectSmali
set injectSmaliDir=%injectOutput%\smali
rem apk反編譯的smali目錄
set smaliDir=%2


echo .........class2dex(apk)..........
call dx --dex --output="%injectApk%" "%injectClassesDir%"
echo .........apk2smali...............
java -jar "_tools\apktool\apktool.jar" d -d -f "%injectApk%" "%injectOutput%"
echo .........copy smali..............
XCOPY "%injectSmaliDir%" "%smaliDir%" /E/Y
