@echo off
REM ============================================
REM EBook Converter Pro - Windows Build Script
REM ============================================
REM 
REM Prerequisites:
REM   1. Python 3.8+ installed
REM   2. Run: pip install -r requirements.txt
REM   3. (Optional) Add icon.ico to assets folder
REM
REM ============================================

echo.
echo ========================================
echo   EBook Converter Pro - Windows Build
echo ========================================
echo.

REM 1a. check python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found in PATH
    echo Please install Python 3.8+ from python.org
    pause
    exit /b 1
)

REM 1b. install dependencies
echo Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

REM 1c. clean previous builds
echo.
echo Cleaning previous builds...
if exist "dist" rmdir /s /q dist
if exist "build" rmdir /s /q build

REM 1d. check for icon
if not exist "assets\icon.ico" (
    echo.
    echo WARNING: No icon.ico found in assets folder
    echo The build will continue without a custom icon
    echo To add an icon, place icon.ico in the assets folder
    echo.
)

REM 1e. run pyinstaller
echo.
echo Building executable...
pyinstaller build_windows.spec --noconfirm
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

REM 1f. create zip package
echo.
echo Creating ZIP package...
cd dist
powershell -Command "Compress-Archive -Path 'EBookConverterPro' -DestinationPath 'EBookConverterPro-Windows.zip' -Force"
cd ..

REM 1g. copy readme
copy docs\README.txt dist\EBookConverterPro\ >nul 2>&1

echo.
echo ========================================
echo   BUILD COMPLETE!
echo ========================================
echo.
echo Output location:
echo   dist\EBookConverterPro\
echo.
echo ZIP package:
echo   dist\EBookConverterPro-Windows.zip
echo.
echo To run the app:
echo   dist\EBookConverterPro\EBookConverterPro.exe
echo.
pause
