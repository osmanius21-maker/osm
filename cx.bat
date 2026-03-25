@echo off
setlocal enabledelayedexpansion
title Ngrok Auto-Update System (Active)

:: ==========================================
:: 1. Configuration
:: ==========================================
:: Note: GITHUB_TOKEN is now pulled from System Environment Variables for security.
set "GH_USER=osmanius21-maker"
set "GH_REPO=osm"
set "LOCAL_PORT=4444"
set "FILE_NAME=link.txt"
set "LOG_FILE=history.log"
set "LAST_LINK=none"

:: ==========================================
:: 2. Launch Ngrok in Background
:: ==========================================
echo [+] Initializing Ngrok on port %LOCAL_PORT%...
start /min cmd /c "ngrok tcp %LOCAL_PORT%"
echo [+] Waiting 12 seconds for tunnel initialization...
timeout /t 12 >nul

:: ==========================================
:: 3. Continuous Monitoring Loop
:: ==========================================
:monitor_loop
cls
echo ==========================================
echo    NGROK AUTO-UPDATE MONITORING
echo ==========================================
echo Status: Running... (Press CTRL+C to stop)
echo Last Known Link: !LAST_LINK!
echo ------------------------------------------

:: Extract current link from Ngrok local API
for /f "delims=" %%i in ('powershell -command "(Invoke-WebRequest -Uri 'http://192.168.1.20:4040/api/tunnels' | ConvertFrom-Json).tunnels.public_url"') do set "CURRENT_LINK=%%i"

:: Check if Ngrok is down
if "!CURRENT_LINK!"=="" (
    echo [!] ALERT: Ngrok API not responding! 
    echo [!] Attempting to restart Ngrok...
    start /min cmd /c "ngrok tcp %LOCAL_PORT%"
    timeout /t 15 >nul
    goto monitor_loop
)

:: Compare current link with the last one pushed
if "!CURRENT_LINK!"=="!LAST_LINK!" (
    echo [%date% %time%] No change detected. Link is stable.
) else (
    echo [%date% %time%] NEW LINK DETECTED: !CURRENT_LINK!
    
    :: Update current link file
    echo !CURRENT_LINK! > %FILE_NAME%
    
    :: Log the change with timestamp
    echo [%date% %time%] New Tunnel: !CURRENT_LINK! >> %LOG_FILE%
    
    echo [+] Syncing with GitHub Repository...
    
    :: Git Commands using Token from Environment Variable
    git add %FILE_NAME% %LOG_FILE%
    git commit -m "Auto-Update: Tunnel changed to !CURRENT_LINK!"
    
    :: Secure Push using Environment Variable %GITHUB_TOKEN%
    git push https://%GH_USER%:%GITHUB_TOKEN%@github.com/%GH_USER%/%GH_REPO%.git main
    
    if !errorlevel! equ 0 (
        set "LAST_LINK=!CURRENT_LINK!"
        echo [+] GitHub Updated Successfully.
    ) else (
        echo [-] Error: Failed to push to GitHub. Check your Internet or Token.
    )
)

:: Wait for 60 seconds before next check
echo ------------------------------------------
echo Next check in 60 seconds...
timeout /t 60 >nul
goto monitor_loop
