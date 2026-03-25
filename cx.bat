@echo off
title Ngrok Auto-Update System (Active)
:: ==========================================
:: 1. Configuration
:: ==========================================
set GITHUB_USER=osmanius21-maker
set GITHUB_REPO=osm
set GITHUB_TOKEN=ghp_K0834MD40W60IOMn18XpiyIwVoHG63vzAIl
set LOCAL_PORT=4444
set FILE_NAME=ip.txt
set LAST_LINK=none

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
echo Last Known Link: %LAST_LINK%
echo ------------------------------------------

:: Extract current link from Ngrok API
for /f "delims=" %%i in ('powershell -command "(Invoke-WebRequest -Uri 'http://192.168.1.20:4040/api/tunnels' | ConvertFrom-Json).tunnels.public_url"') do set CURRENT_LINK=%%i

:: Check if Ngrok is down
if "%CURRENT_LINK%"=="" (
    echo [!] ALERT: Ngrok API not responding! 
    echo [!] Attempting to restart Ngrok...
    start /min cmd /c "ngrok tcp %LOCAL_PORT%"
    timeout /t 15 >nul
    goto monitor_loop
)

:: Compare current link with the last one pushed
if "%CURRENT_LINK%"=="%LAST_LINK%" (
    echo [%time%] No change detected. Link is stable.
) else (
    echo [%time%] NEW LINK DETECTED: %CURRENT_LINK%
    echo %CURRENT_LINK% > %FILE_NAME%
    
    echo [+] Syncing with GitHub...
    git add %FILE_NAME%
    git commit -m "Auto-Update: Tunnel changed to %CURRENT_LINK%"
    git push https://%GITHUB_USER%:%GITHUB_TOKEN%@github.com/%GITHUB_USER%/%GITHUB_REPO%.git main
    
    set LAST_LINK=%CURRENT_LINK%
    echo [+] GitHub Updated Successfully.
)

:: Wait for 60 seconds before checking again
echo ------------------------------------------
echo Next check in 60 seconds...
timeout /t 60 >nul
goto monitor_loop
