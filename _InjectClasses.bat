@echo off

echo ***********************************
echo �N�ۤv�g��class�V�s(�`�J)��ݭn�ϽsĶ��apk(mix/inject classes2apk)
echo ==================================
echo v1.0 20121024 by Sun https://onekey-decompile-apk.googlecode.com/svn/trunk

echo !
echo �\��
echo --------
echo 1. �N�ۤv�g��class�ɮ��ܦ�android��dex�榡
echo 2. �Ndex�榡�ϽsĶ��smali�N�X
echo 3. �X�ֳo��smali�N�X��apk�ϽsĶ��smali�ؿ�

echo ?
echo �ϥΤ�k
echo --------
echo _inject_classes {class�ؿ�} {apk�ϽsĶ��smali�ؿ�}
echo �Ҧp: _inject_classes D:\TestSmaliInject\build\classes D:\TestSmali\smali
echo ***********************************


rem classes�ؿ�
set injectClassesDir=%1
set injectApk=%injectClassesDir%\..\inject.apk
set injectOutput=%injectClassesDir%\..\injectSmali
set injectSmaliDir=%injectOutput%\smali
rem apk�ϽsĶ��smali�ؿ�
set smaliDir=%2


echo .........class2dex(apk)..........
call dx --dex --output="%injectApk%" "%injectClassesDir%"
echo .........apk2smali...............
java -jar "_tools\apktool\apktool.jar" d -d -f "%injectApk%" "%injectOutput%"
echo .........copy smali..............
XCOPY "%injectSmaliDir%" "%smaliDir%" /E/Y
