flutter build appbundle && echo - ^
 && echo APP BUNDLE BUILD DONE && echo - ^
 && flutter build apk --target-platform android-arm,android-arm64,android-x64 --split-per-abi && echo - ^
 && echo APK BUILD DONE && echo - ^
 && flutter build web && echo - ^
 && echo WEB BUILD DONE && echo - ^
 && cd ./build/web && del /f web.zip && "C:\Program Files\7-Zip\7z.exe" a -tzip web.zip * && copy web.zip "../app/outputs/apk/release" && cd ../../ && echo - ^
 && echo WEB ZIPPED && echo - ^
 && flutter build windows && echo - ^
 && echo WINDOWS BUILD DONE && echo - ^
 && cd ./build/windows && del /f windows.zip && "C:\Program Files\7-Zip\7z.exe" a -tzip windows.zip * && copy windows.zip "../app/outputs/apk/release" && cd ../../ && echo - ^
 && echo WINDOWS ZIPPED && echo - ^
 && del /f "build/app/outputs/apk/release/output.json" && echo - ^
 && echo CLEANED RELEASE FOLDER && echo -