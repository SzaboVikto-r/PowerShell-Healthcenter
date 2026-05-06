@echo off
powershell.exe -ExecutionPolicy Bypass -NonInteractive -File "%~dp0Collect-DiskInfo.ps1"
if %errorlevel% neq 0 (
    echo.
    echo [HIBA] A script nem futott le sikeresen. Kod: %errorlevel%
    pause
)
