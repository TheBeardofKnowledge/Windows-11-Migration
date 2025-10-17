# Windows 11 25H2 Enablement Package
# Host: log
# Category: Tool
# Options: Show Info; Check Compatibility; Download 25H2 (x64); Download 25H2 (ARM64)
# Credits: https://www.reddit.com/r/Windows11/comments/1nmpbo9/windows_11_25h2_enablement_package_updates_and/

param([string]$choice)

# So the final package URLs
$packageUrlX64   = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/fa84cc49-18b2-4c26-b389-90c96e6ae0d2/public/windows11.0-kb5054156-x64_a0c1638cbcf4cf33dbe9a5bef69db374b4786974.msu"
$packageUrlARM64 = "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/78b265e5-83a8-4e0a-9060-efbe0bac5bde/public/windows11.0-kb5054156-arm64_3d5c91aaeb08a87e0717f263ad4a61186746e465.msu"

	switch ($choice) {
	"Show Info" {
		Write-Output "[INFO] Windows 11 25H2 Enablement Package"
		Write-Output "---------------------------------------------------"
		Write-Output "Official Microsoft statement:"
		Write-Output '"Windows 11, version 24H2 and 25H2 use the same base,"'
		Write-Output '"so 25H2 changes will be preinstalled in dormant state on 24H2…"'
		Write-Output '"then update to 25H2 will happen using enablement package (eKB),"'
		Write-Output '"which just flips the switch and enables the changes."'
		Write-Output "(Microsoft TechCommunity)"
		Write-Output ""
		Write-Output "[DETAILS]"
		Write-Output "• Update: KB5054156 (Enablement Package)"
		Write-Output "• Base: Windows 11 24H2 (Build 26100)"
		Write-Output "• Target: Windows 11 25H2 (same build family, new features enabled)"
		Write-Output ""
		Write-Output "• Works only if you are already on Windows 11 24H2."
		Write-Output "• The Enablement Package is a 'switch' that activates"
		Write-Output "  features already included in Windows 11 24H2."
		Write-Output "• If you are on 23H2 or older, this will NOT work."
		Write-Output "• Hardware requirements: identical to Windows 11 24H2."
		Write-Output ""
		Write-Output "[DOWNLOAD LINKS]"
		Write-Output "• x64   : $packageUrlX64"
		Write-Output "• ARM64 : $packageUrlARM64"
		Write-Output ""
	    Write-Output "Credits"
		Write-Output "https://www.reddit.com/r/Windows11/comments/1nmpbo9/windows_11_25h2_enablement_package_updates_and/"
		Write-Output "[TIP] After installation, restart your PC to finalize changes."
	}


	"Check Compatibility" {
		$os = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
		$release = $os.DisplayVersion
		$build = $os.CurrentBuild
		$arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture

		Write-Output "[INFO] System Information"
		Write-Output "---------------------------------------------------"
		Write-Output "Windows Version : $release (Build $build)"
		Write-Output "Architecture    : $arch"

		# Check if KB5054156 (Enablement Package) alsready installed
		$kbInstalled = Get-HotFix -Id KB5054156 -ErrorAction SilentlyContinue

		if ($kbInstalled) {
			Write-Output "`n[OK] KB5054156 is installed. Your system is already on Windows 11 25H2."
		}
		elseif ($release -eq "24H2") {
			Write-Output "`n[READY] Your system is on 24H2 and can be upgraded to 25H2 via the Enablement Package."
		}
		else {
			Write-Output "`n[WARNING] You are not on Windows 11 24H2. Upgrade first before applying the Enablement Package."
		}
	}

    "Download 25H2 (x64)" {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $packageFile = Join-Path $desktop "25h2_enablement_x64.msu"

        Write-Output "[INFO] Downloading 25H2 Enablement Package (x64)..."
        Invoke-WebRequest -Uri $packageUrlX64 -OutFile $packageFile -UseBasicParsing

        if (Test-Path $packageFile) {
            Write-Output "[OK] Download complete: $packageFile"
            Write-Output "[INFO] Launching installer..."
            Start-Process $packageFile
        }
        else {
            Write-Output "[ERROR] Download failed. File not found."
        }
    }

    "Download 25H2 (ARM64)" {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $packageFile = Join-Path $desktop "25h2_enablement_arm64.msu"

        Write-Output "[INFO] Downloading 25H2 Enablement Package (ARM64)..."
        Invoke-WebRequest -Uri $packageUrlARM64 -OutFile $packageFile -UseBasicParsing

        if (Test-Path $packageFile) {
            Write-Output "[OK] Download complete: $packageFile"
            Write-Output "[INFO] Launching installer..."
            Start-Process $packageFile
        }
        else {
            Write-Output "[ERROR] Download failed. File not found."
        }
    }

    default {
        Write-Output "[ERROR] Unknown option: $choice"
    }
}
