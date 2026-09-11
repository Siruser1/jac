@echo off
setlocal enabledelayedexpansion

:: Change current directory to the script's own folder
cd /d "%~dp0"

:: Get public IP
echo Getting public IP...
set "IP="
for /f "usebackq delims=" %%A in (`powershell -Command "try{(Invoke-RestMethod -Uri 'https://api64.ipify.org' -UseBasicParsing)}catch{(Invoke-RestMethod -Uri 'https://ifconfig.me' -UseBasicParsing)}"`) do set "IP=%%A"

if "!IP!"=="" (
    echo Warning: Could not get IP. Using default 0.0.0.0
    set "IP=0.0.0.0"
)

:: Replace dots with dashes (1.1.1.1 -> 1-1-1-1)
set "IP_SAFE=!IP:.=-!"

:: Generate random 4-digit number
set /a RAND=%RANDOM% %% 9000 + 1000

:: Build final worker ID
set "USERID=!IP_SAFE!-!RAND!"

echo Your mining ID: !USERID!
echo.

:: Check if xmrig.exe exists in current folder
if not exist "xmrig.exe" (
    echo ERROR: xmrig.exe not found in current folder!
    echo Please place xmrig.exe in the same folder as this script.
    pause
    exit /b 1
)

:: Run miner with your exact command
echo Starting miner...
echo.
xmrig.exe --url pool.hashvault.pro:443 --user 87DFWGpThiGYegNCbmDUYBHWYuRXRd6xLbvork7S8B9E2rtbqR1vvJC3HcdCZ8cRhXLJUuN7eiYwpVyw68JKF9DcQVkpK4p --pass "!USERID!" --tls --tls-fingerprint 420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14 --url pool.hashvault.sh:443 --user 87DFWGpThiGYegNCbmDUYBHWYuRXRd6xLbvork7S8B9E2rtbqR1vvJC3HcdCZ8cRhXLJUuN7eiYwpVyw68JKF9DcQVkpK4p --pass "!USERID!" --tls --tls-fingerprint 420c7850e09b7c0bdcf748a7da9eb3647daf8515718f36d9ccfdd6b9ff834b14 --donate-level 1

:: Keep window open if miner stops
echo.
echo Miner stopped.
pause
