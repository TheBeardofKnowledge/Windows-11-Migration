:::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights
:::::::::::::::::::::::::::::::::::::::::
@ECHO OFF
color f0
ECHO =============================
ECHO Running Admin shell
ECHO =============================
 
:checkPrivileges 
NET FILE 1>NUL 2>NUL
	if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 
:getPrivileges
::method 1 - using powershell
::@echo off
    :: Not elevated, so re-run with elevation
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0 %*' -Verb RunAs"
    exit /b
)
:gotPrivileges 
::::::::::::::::::::::::::::
:STARTINTRO
::::::::::::::::::::::::::::
::cls
@ECHO OFF

powershell.exe -c Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
::powershell.exe - c Set-PSRepository
PowerShell.exe -c Install-Module -Name Microsoft.WinGet.Client -Force
winget update --all --include-unknown --accept-source-agreements --accept-package-agreements --silent --verbose
PAUSE
::to exclude a package use
::winget pin add --name "Micron Storage Executive" --blocking
::to remove a package from pin use
::winget pin remove --name "Micron Storage Executive"
popd