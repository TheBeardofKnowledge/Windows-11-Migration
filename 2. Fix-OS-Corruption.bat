@ECHO OFF
color f0

ECHO Running Admin shell
ECHO ::::::::::::::::::::::::::::::::::::::::::::
ECHO :: Automatically check & get admin rights ::
ECHO ::::::::::::::::::::::::::::::::::::::::::::
 
:checkPrivileges 
NET FILE 1>NUL 2>NUL
	if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 
:getPrivileges
:: Not elevated, so re-run with elevation
	powershell -Command "Start-Process cmd -ArgumentList '/c %~s0 %*' -Verb RunAs"
    exit /b
)
:gotPrivileges 
::::::::::::::::::::
::START OF SCRIPT ::
::::::::::::::::::::
@ECHO OFF
ECHO Checking your Windows Drive for Errors
	chkdsk /scan /perf /sdcleanup /forceofflinefix c:
ECHO Checking Windows System Files for Errors
	sfc /scannow
ECHO Checking image health
dism /online /cleanup-image /scanhealth

ECHO Restoring image health
dism /online /cleanup-image /restorehealth

ECHO Starting component cleanup
dism.exe /online /Cleanup-Image /StartComponentCleanup

ECHO Resetting base image
dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

ECHO Repairing Windows Management Instrumentation 
::WMIcorruptionfix

echo Re-registering WMI Components and Recompiling MOFs ---

echo This is an aggressive repair. It will stop the WMI service,
echo re-register all WMI-related DLLs, and recompile all standard
echo MOF files in the WBEM directory.
echo Disabling and stopping the WMI service...
	sc config winmgmt start= disabled
	net stop winmgmt /y

echo Changing directory to the WBEM folder...
	cd /d %windir%\system32\wbem

echo registering all provider DLLs (this may take a moment)...
:: This loop uses corrected syntax to iterate through all DLLs.
	for /f %%s in ('dir /b *.dll') do (
	    echo Registering %%s...
	    regsvr32 /s %%s
	)
echo DLL registration complete.

echo Recompiling MOF and MFL files (excluding uninstallers)...
:: This command creates a list of MOF/MFL files, filters out any
:: containing "uninstall", and then compiles the files from that list.
	dir /b *.mof *.mfl | findstr /v /i "uninstall" > moflist.txt
	for /f %%s in (moflist.txt) do (
	    echo Compiling %%s...
	    mofcomp %%s
	)
	del moflist.txt
echo MOF compilation complete.

echo Re-enabling and starting the WMI service...
	sc config winmgmt start= auto
	net start winmgmt


ECHO Registering AppXPackages
::Powershell
::Fix Windows Store
PowerShell -ExecutionPolicy Unrestricted -C "& {Add-AppxPackage -DisableDevelopmentMode -Register ((Get-AppxPackage *Microsoft.WindowsStore*).InstallLocation + '\AppxManifest.xml')}"

PowerShell -noexit -c "Get-AppXPackage | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_. InstallLocation + '\appxmanifest.xml')}"

PowerShell -noexit -c "Get-AppxPackage Microsoft.Windows.ShellExperienceHost | foreach {Add-AppxPackage -register "$($_. InstallLocation + '\appxmanifest.xml') -DisableDevelopmentMode}"

::end of script
exit
ECHO Service is complete, please restart the pc for the changes to take effect.
PAUSE
