@echo off
REM ========================================
REM EBook Converter Pro - Quick Launcher
REM ========================================
REM
REM This runs the app directly with Python.
REM If you want a standalone .exe, run:
REM   build_scripts\build_windows.bat
REM
REM ========================================

echo Starting EBook Converter Pro...

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: Python is not installed or not in PATH
    echo.
    echo Please install Python 3.8+ from:
    echo   https://www.python.org/downloads/
    echo.
    echo Make sure to check "Add Python to PATH" during installation!
    echo.
    pause
    exit /b 1
)

REM Install dependencies if needed
if not exist ".deps_installed" (
    echo Installing dependencies...
    pip install -r requirements.txt
    echo. > .deps_installed
)

REM Run the application
python src\main.py

if errorlevel 1 (
    echo.
    echo An error occurred. Press any key to exit.
    pause
)

