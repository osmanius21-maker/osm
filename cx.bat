@echo off
:: ==========================================
:: 1. Your GitHub Credentials
:: ==========================================
set GITHUB_USER=osmanius21-maker
set GITHUB_REPO=osm
set GITHUB_TOKEN=ghp_K0834MD40W60IOMn18XpiyIwVoHG63vzAIl
set LOCAL_PORT=4444
set FILE_NAME=cx.bat

:: ==========================================
:: 2. Launch Ngrok
:: ==========================================
echo [+] Starting Ngrok TCP on port %LOCAL_PORT%...
start "" ngrok tcp %LOCAL_PORT%

:: Wait 10 seconds for Ngrok to initialize and generate the URL
echo [+] Waiting for Ngrok API to initialize...
timeout /t 10 >nul

:: ==========================================
:: 3. Extract the TCP URL (Using PowerShell for Accuracy)
:: ==========================================
echo [+] Fetching public URL from Ngrok API...
for /f "delims=" %%i in ('powershell -command "(Invoke-WebRequest -Uri 'http://127.0.0.1:4040/api/tunnels' | ConvertFrom-Json).tunnels.public_url"') do set NEW_LINK=%%i

:: Check if the variable is empty (Ngrok failed to start or API unreachable)
if "%NEW_LINK%"=="" (
    echo [!] Error: Could not fetch Ngrok URL. Make sure Ngrok is running.
    pause
    exit /b
)

echo %NEW_LINK% > %FILE_NAME%
echo [!] NEW LINK DETECTED: %NEW_LINK%

:: ==========================================
:: 4. Git Commands to Push to GitHub
:: ==========================================
echo [+] Syncing with remote repository...
:: Pull first to avoid "non-fast-forward" errors
git pull https://%GITHUB_USER%:%GITHUB_TOKEN%@github.com/%GITHUB_USER%/%GITHUB_REPO%.git main

echo [+] Uploading updated link to GitHub...
git add %FILE_NAME%
git commit -m "Auto-update Ngrok link: %date% %time%"

:: Push using the authenticated URL
git push https://%GITHUB_USER%:%GITHUB_TOKEN%@github.com/%GITHUB_USER%/%GITHUB_REPO%.git main

echo.
echo [+] SUCCESS! Your "Static" GitHub Raw Link is:
echo https://raw.githubusercontent.com/%GITHUB_USER%/%GITHUB_REPO%/main/%FILE_NAME%
pause
