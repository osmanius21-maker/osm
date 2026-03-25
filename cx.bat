@echo off
setlocal enabledelayedexpansion
title Windows PATH Error Finder & Fixer

:menu
cls
echo ==========================================
echo      SYSTEM PATH ERROR DIAGNOSTICS
echo ==========================================
echo 1) Scan for Broken Paths (Invalid Folders)
echo 2) Auto-Remove Invalid Paths (User)
echo 3) Auto-Remove Invalid Paths (System - Admin)
echo 4) List All Paths (Detailed)
echo 5) Exit
echo ==========================================
set /p choice="Select option [1-5]: "

if "%choice%"=="1" goto scan_path
if "%choice%"=="2" goto fix_user
if "%choice%"=="3" goto fix_system
if "%choice%"=="4" goto list_all
if "%choice%"=="5" exit
goto menu

:scan_path
cls
echo [Scanning for non-existent folders in PATH...]
echo ------------------------------------------
powershell -NoProfile -Command "$env:Path -split ';' | ForEach-Object { if (-not (Test-Path $_) -and $_ -ne '') { Write-Host '[INVALID]: ' $_ -ForegroundColor Red } else { if ($_ -ne '') { Write-Host '[VALID]:   ' $_ -ForegroundColor Green } } }"
echo ------------------------------------------
pause
goto menu

:fix_user
cls
echo [Repairing User PATH...]
powershell -NoProfile -Command "$old = [Environment]::GetEnvironmentVariable('Path', 'User'); $new = ($old -split ';' | Where-Object { (Test-Path $_) -and $_ -ne '' }) -join ';'; [Environment]::SetEnvironmentVariable('Path', $new, 'User'); Write-Host 'User PATH cleaned from invalid entries.' -ForegroundColor Green"
pause
goto menu

:fix_system
cls
echo [Repairing System PATH - Requesting Admin...]
powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList \"-NoProfile -Command $old = [Environment]::GetEnvironmentVariable('Path', 'Machine'); $new = ($old -split ';' | Where-Object { (Test-Path $_) -and $_ -ne '' }) -join ';'; [Environment]::SetEnvironmentVariable('Path', $new, 'Machine'); Write-Host 'System PATH cleaned successfully.' -ForegroundColor Green\""
pause
goto menu

:list_all
cls
echo [Full PATH List]
powershell -NoProfile -Command "$env:Path -split ';' | Where-Object { $_ -ne '' }"
pause
goto menu
