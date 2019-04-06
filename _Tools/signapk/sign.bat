
@ECHO OFF

java -jar signapk.jar testkey.x509.pem testkey.pk8 %1 %2

Echo Signing Complete 
 
PAUSE