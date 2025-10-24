Want a smooth in-place upgrade from Windows 10 to Windows 11?
I've used these tools to successfully upgrade over 120 computers so far, supported and unsupported.
The trick is to get your Windows 10 installation in a good state so the Windows 11 OS can migrate it properly,
  and after it's done installing optimize and debloat it's settings and features.

Download all the Files here and put them into the same folder.  Something like c:\win11upgrade

Procedure:
1. Run Windows update on your existing Windows 10 pc until there are no more updates left. Windows 10 Pro/Home should be on 22H2
2. Run the included "PreInstall.bat" file.  This will not only free up disk space but also check and repair system corruption.
   A reboot is required, and at reboot it will check your operating system drive for any disk corruption.
3. Get a good copy of the Windows 11 ISO:
   You can use the included Windows11MediaCreationTool.exe (which is the working version from Microsoft before they broke it).
   Choose the option to create ISO file, and save the iso into the same folder as these files you downloaded.
   What I highly recommend is after downloading the Microsoft ISO, trim it down using Tiny11Builder from NTDev:
   https://github.com/ntdevlabs/tiny11builder/blob/main/tiny11maker.ps1
5. Run Windows11Install.bat  This will search the folder it is in for any .iso files (you should only have 1 there) and mount
   it in system, then it will autorun the Windows installer with customized options to simply upgrade
   The command it runs is: .\sources\setupprep.exe /product server /auto upgrade /dynamicupdate disable /eula accept

After Windows Upgrade completes:

     Disk Space: Be aware of your disk space immediately after an upgrade because not only is Windows 11 installed,
     but your Windows 10 installation is still there for a bit, by default is 10 days.
     You can give yourself more time in that window of time by opening command/terminal as administrator and run:
   
     DISM /Online /Set-OSUninstallWindow /Value:60
   
     This will give you the maximum of 60 days before the previous operating system version is automatically deleted.
   If you are sure you will be keeping Windows 11, you can run cleanmgr and clean system files to delete everything.

     FlyOOBE: Original Project can be found at https://github.com/builtbybel/FlyOOBE
   This utility (and subutilities will be crucial in improving your Windows 11 experience as it has various tweaks to:
   *debloat Windows 11 of programs you dont want, and also remove the forced Ai features of Co-Pilot
   
   *optimize the responsiveness of Windows 11 by disabling things that cause lag.

   *In Finalize Setup, run the extension for the ChrisTitusApp, go to tweaks, and apply recommended.
