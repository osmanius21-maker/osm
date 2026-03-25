@echo off
setlocal

:: ================= CONFIGURATION =================
:: 1. Your GitHub Username
set GITHUB_USER=osmanius21-maker

:: 2. Your Repository Name (e.g., "my-links")
set GITHUB_REPO=osm

:: 3. Your GitHub Classic Token (ghp_xxxxxxxxxxxx)
set GITHUB_TOKEN=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

:: 4. The local port you want to tunnel
set LOCAL_PORT=4444

:: 5. The filename to store the link on GitHub
set FILE_NAME=cx.bat
:: =================================================

echo [+] Starting Ngrok TCP on port %LOCAL_PORT%...
start "" ngrok tcp %LOCAL_PORT%

:: Wait 10 seconds for Ngrok to connect and generate the URL
echo [+] Waiting for Ngrok API to initialize...
timeout /t 10 >nul

:: Extract the new TCP URL from Ngrok's local API (Port 4040)
curl -s http://127.0.0.1 | findstr /r "tcp://[0-9a-z.]*:[0-9]*" > %FILE_NAME%

echo [!] NEW LINK DETECTED:
type %FILE_NAME%

:: Check if the file is empty (Ngrok failed to start)
for /f "usebackq delims=" %%A in ("%FILE_NAME%") do set NEW_LINK=%%A
if "%NEW_LINK%"=="" (
    echo [!] Error: Could not fetch Ngrok URL. Make sure Ngrok is running.
    pause
    exit /b
)

:: Git commands to push the updated link to GitHub
echo [+] Uploading to GitHub Repository...
git add %FILE_NAME%
git commit -m "Auto-update Ngrok TCP link: %date% %time%"
git push https://%GITHUB_TOKEN%@://github.com main

echo.
echo [+] SUCCESS! Your "Static" GitHub Raw Link is:
echo https://raw.githubusercontent.com%
echo.
pause
