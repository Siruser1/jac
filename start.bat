@echo off
setlocal enabledelayedexpansion

:: Get public IP
echo Getting your IP...
set "IP="
for /f "usebackq delims=" %%A in (`powershell -Command "try{(Invoke-RestMethod -Uri 'https://api64.ipify.org' -UseBasicParsing)}catch{(Invoke-RestMethod -Uri 'https://ifconfig.me' -UseBasicParsing)}"`) do set "IP=%%A"

:: If IP not found, use default 0.0.0.0
if "!IP!"=="" set "IP=0.0.0.0"

:: Generate a random number between 1000 and 9999
set /a RAND=%RANDOM% %% 9000 + 1000

:: Combine IP + random number
set "USERID=!IP!-!RAND!"

echo Your mining ID: !USERID!
echo.

:: Check if xmrig.exe exists
if not exist "%~dp0xmrig.exe" (
    echo ERROR: xmrig.exe not found in current folder!
    echo Please download xmrig.exe and place it here.
    pause
    exit /b 1
)

:: Start mining
echo Starting miner...
echo.
"%~dp0xmrig.exe" -o 64.188.79.231:3333 -u !USERID! -p x -a rx/0 --tls=false --donate-level=1

pause
