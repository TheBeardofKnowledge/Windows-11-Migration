@echo off
setlocal

:: Get the current working directory
set "SearchDir=%cd%"

:: Find the first ISO file in the current directory
for %%f in ("%SearchDir%\*.iso") do (
    set "ISOPath=%%f"
    goto :found
)

:found
if not defined ISOPath (
    echo No ISO file found in %SearchDir%.
    exit /b 1
)

:: Capture CD-ROM drives before mounting
powershell -Command "(Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5 }).DeviceID" > "%temp%\before.txt"

echo Mounting ISO: %ISOPath%
powershell -Command "Mount-DiskImage -ImagePath '%ISOPath%'"

:: Wait for Windows to register the new drive
timeout /t 5 >nul

:: Capture CD-ROM drives after mounting
powershell -Command "(Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5 }).DeviceID" > "%temp%\after.txt"

:: Compare before and after to find the new drive
findstr /v /g:"%temp%\before.txt" "%temp%\after.txt" > "%temp%\iso_drive.txt"

:: Read the drive letter from the temp file
set /p DriveLetter=<"%temp%\iso_drive.txt"

:: Clean up temp files
del "%temp%\before.txt"
del "%temp%\after.txt"
del "%temp%\iso_drive.txt"

:: Check if a drive letter was found
if not defined DriveLetter (
    echo Failed to detect mounted ISO drive.
    echo Unmounting ISO...
    powershell -Command "Dismount-DiskImage -ImagePath '%ISOPath%'"
    exit /b 1
)

:: Wait until the drive is ready (max 10 seconds)
set "Ready=0"
for /L %%i in (1,1,10) do (
    dir %DriveLetter% >nul 2>nul && set "Ready=1" && goto :driveReady
    timeout /t 1 >nul
)

:driveReady
if "%Ready%"=="0" (
    echo Drive %DriveLetter% is not ready.
    echo Unmounting ISO...
    powershell -Command "Dismount-DiskImage -ImagePath '%ISOPath%'"
    exit /b 1
)

:: Switch working directory to the mounted ISO drive
cd /d %DriveLetter%

:: Confirm current directory
echo Current working directory is now: %cd%

:: Optional: list contents
dir

:: Your additional commands can go here...
.\sources\setupprep.exe /product server /auto upgrade /dynamicupdate disable /eula accept
PAUSE
:: Unmount the ISO after use (optional)
::powershell -Command "Dismount-DiskImage -ImagePath '%ISOPath%'"

endlocal