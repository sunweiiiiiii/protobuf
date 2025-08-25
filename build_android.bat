@echo off
setlocal

REM Set NDK path
set ANDROID_NDK=C:\Users\miles\AppData\Local\Android\Sdk\ndk\29.0.13846066
set ANDROID_ABI=arm64-v8a
set ANDROID_PLATFORM=android-21
set BUILD_DIR=protobuf_build_android

REM Check cmake
where cmake >nul 2>nul
if errorlevel 1 (
    echo [ERROR] cmake not found in PATH.
    exit /b 1
)

REM Check ninja
where ninja >nul 2>nul
if errorlevel 1 (
    set GENERATOR=NMake Makefiles
    echo [INFO] Using NMake Makefiles generator.
) else (
    set GENERATOR=Ninja
    echo [INFO] Using Ninja generator.
)

REM Create build dir
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%

REM Configure cmake (all in one line) -DBUILD_SHARED_LIBS=ON for .so
cmake .. -G "%GENERATOR%" -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%\build\cmake\android.toolchain.cmake -DANDROID_ABI=%ANDROID_ABI% -DANDROID_PLATFORM=%ANDROID_PLATFORM% -DCMAKE_BUILD_TYPE=Release -Dprotobuf_BUILD_TESTS=OFF

REM Build
cmake --build . --config Release

cd ..
echo Build complete. The .so files are in %BUILD_DIR%.
pause