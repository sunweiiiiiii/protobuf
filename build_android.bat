@echo off
setlocal

REM Set NDK path (recommend setting this as an environment variable or passing as argument for flexibility)
set ANDROID_NDK=C:\Users\miles\AppData\Local\Android\Sdk\ndk\29.0.13846066
set ANDROID_ABI=arm64-v8a
set ANDROID_PLATFORM=android-21
set BUILD_DIR=protobuf_build_android
set INSTALL_DIR=protobuf_install_android

REM Check cmake
where cmake >nul 2>nul
if errorlevel 1 (
    echo [ERROR] cmake not found in PATH. Please install CMake and add it to PATH.
    exit /b 1
)

REM Check ninja (preferred for Android NDK builds)
where ninja >nul 2>nul
if errorlevel 1 (
    echo [WARNING] Ninja not found in PATH. Falling back to NMake, but ensure Visual Studio is installed.
    set GENERATOR=NMake Makefiles
    REM Set up Visual Studio environment for NMake (adjust path to your VS version)
    call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" amd64_arm64 >nul 2>nul
    if errorlevel 1 (
        echo [ERROR] Failed to set up Visual Studio environment for NMake. Please check VS installation.
        exit /b 1
    )
    echo [INFO] Using NMake Makefiles generator.
) else (
    set GENERATOR=Ninja
    echo [INFO] Using Ninja generator.
)

REM Create build and install directories
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
if not exist %INSTALL_DIR% mkdir %INSTALL_DIR%

REM Navigate to build dir
cd %BUILD_DIR%

REM Configure CMake for Android protobuf static library
cmake .. ^
    -G "%GENERATOR%" ^
    -DCMAKE_TOOLCHAIN_FILE=%ANDROID_NDK%\build\cmake\android.toolchain.cmake ^
    -DANDROID_ABI=%ANDROID_ABI% ^
    -DANDROID_PLATFORM=%ANDROID_PLATFORM% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -Dprotobuf_BUILD_TESTS=OFF ^
    -Dprotobuf_BUILD_SHARED_LIBS=OFF ^
    -Dprotobuf_BUILD_PROTOC_BINARIES=OFF ^
    -Dprotobuf_WITH_ZLIB=OFF ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_INSTALL_PREFIX=../%INSTALL_DIR%

if errorlevel 1 (
    echo [ERROR] CMake configuration failed.
    cd ..
    exit /b 1
)

REM Build the project
cmake --build . --config Release --parallel 8

if errorlevel 1 (
    echo [ERROR] Build failed.
    cd ..
    exit /b 1
)

REM Install the built files (including .a and include headers) to install dir
cmake --install . 

if errorlevel 1 (
    echo [ERROR] Installation failed.
    cd ..
    exit /b 1
)

cd ..
echo Build complete. The .a files are in %INSTALL_DIR%\lib (e.g., libprotobuf.a or libprotobuf-lite.a).
echo The necessary include headers are in %INSTALL_DIR%\include (e.g., google/protobuf/message.h).
echo Note: For multi-ABI support, run this script multiple times with different ANDROID_ABI values (e.g., armeabi-v7a, x86_64).
pause