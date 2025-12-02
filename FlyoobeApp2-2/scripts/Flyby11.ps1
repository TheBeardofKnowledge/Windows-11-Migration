# Description: Launch and manage the Flyby11 helper (Windows 10 > Windows 11 Upgrade tool).
# Category: Tool
# Host: log
# Options: Run Flyby11; Check version; Open exe folder; Open Releases page; Help
# PoweredBy: Belim
# PoweredUrl: https://github.com/builtbybel/Flyoobe

[CmdletBinding()]
param(
    [string]$Option,
    [string]$ArgsText
)

# --------------------------
# Helpers
# --------------------------
function Get-BaseDir {
    try { return [AppDomain]::CurrentDomain.BaseDirectory }
    catch { return (Get-Location).Path }
}

function Resolve-FlybyExe {
    param([string]$base = (Get-BaseDir))

    # 1) Prefer exact known folder ./scripts/Flyby11/Flyby11.exe
    $exact = Join-Path $base 'scripts\Flyby11\Flyby11.exe'
    if (Test-Path $exact) { return (Get-Item $exact).FullName }

    # 2) If folder exists, pick any exe inside (in case the filename differs)
    $folder = Join-Path $base 'scripts\Flyby11'
    if (Test-Path $folder) {
        $any = Get-ChildItem -Path $folder -Filter '*.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($any) { return $any.FullName }
    }

    # 3) Common roots to search (scripts, script root, base)
    $roots = @(
        (Join-Path $base 'scripts'),
        $PSScriptRoot,
        $base
    ) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -Unique

    foreach ($r in $roots) {
        try {
            $found = Get-ChildItem -Path $r -Recurse -File -Include 'Flyby11.exe','*Flyby11*.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($found) { return $found.FullName }
        } catch { }
    }

    # 4) Last resort: any exe named like Flyby*.exe anywhere under scripts
    try {
        $fallback = Get-ChildItem -Path (Join-Path $base 'scripts') -Recurse -File -Include 'Flyby*.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($fallback) { return $fallback.FullName }
    } catch { }

    return $null
}


function Get-FileVersion {
    param([string]$path)
    try {
        $v = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($path)
        return $v.FileVersion
    } catch { return $null }
}

function Start-Flyby {
    param([string]$exePath, [string]$args)

    if (-not (Test-Path $exePath)) { throw "Executable not found: $exePath" }

    Write-Output "Starting Flyby11: $exePath"
    if (-not [string]::IsNullOrWhiteSpace($args)) {
        Write-Output "Arguments: $args"
    }

    # Start the GUI exe without opening a PS console
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $exePath
        if (-not [string]::IsNullOrWhiteSpace($args)) { $startInfo.Arguments = $args }
        $startInfo.UseShellExecute = $true
        $proc = [System.Diagnostics.Process]::Start($startInfo)
        if ($proc -ne $null) {
            Write-Output "Flyby11 started (PID $($proc.Id))."
            # $proc.WaitForExit(); Write-Output "Flyby11 exited with code $($proc.ExitCode)."
        } else {
            throw "Process.Start returned null."
        }
    } catch {
        throw "Failed to start Flyby11: $($_.Exception.Message)"
    }
}

function Open-Folder {
    param([string]$path)
    if (-not (Test-Path $path)) { throw "Path not found: $path" }
    Start-Process explorer.exe -ArgumentList ("/select,`"$path`"")
}

function Open-Url {
    param([string]$url)
    if ([string]::IsNullOrWhiteSpace($url)) { throw "No URL specified." }
    try { Start-Process $url } catch { throw "Failed to open URL: $($_.Exception.Message)" }
}


function Show-Help {
    Write-Output "Flyby11 Upgrade Assistant — How-to"
    Write-Output "------------------------------------------------------------"
    Write-Output "1) Download source"
    Write-Output "   - Choose a download source in the assistant (Microsoft ISO, Media Creation Tool, or local ISO)."
    Write-Output "   - We recommend using the Media Creation Tool if you want to keep apps and settings."
    Write-Output ""
    Write-Output "2) Prepare the ISO"
    Write-Output "   - If you used the Media Creation Tool: create the ISO and save it locally."
    Write-Output "   - If you downloaded an official Microsoft ISO, keep note where it is saved."
    Write-Output ""
    Write-Output "3) Apply the patch (Patch Action)"
    Write-Output "   - Drag & drop the downloaded ISO into the dashed 'Patch Action' box in the assistant"
    Write-Output "     (or click the box to select the ISO from disk)."
    Write-Output "   - Follow the on-screen assistant steps to run the autopilot/patch process."
    Write-Output "   - The bypass will be applied automatically during the upgrade process."
    Write-Output ""
    Write-Output "4) Advanced Options"
    Write-Output "   - Use the 'Advanced Options' dropdown to enable extra behaviors."
    Write-Output "   - Example: Join the ESU (Extended Security Updates) program for Windows 10"
    Write-Output "     (only use if you have the proper entitlement/licensing)."
    Write-Output ""
    Write-Output "5) Notes & Tips"
    Write-Output "   - Run this helper as Administrator when requested (UAC may appear)."
    Write-Output "   - Make a backup or system image before major upgrades if possible."
    Write-Output "   - If you want to keep apps & settings, prefer the Media Creation Tool ISO."
    Write-Output "   - If something fails, use 'Open exe folder' to confirm Flyby11.exe is present."
    Write-Output ""
    Write-Output "6) Help & Releases"
    Write-Output "   - Use 'Open Releases page' to download the latest Flyby11 helper manually."
    Write-Output "   - If you need step-by-step screenshots or a guide, check the repository page."
    Write-Output "------------------------------------------------------------"
}
# --------------------------
# Main
# --------------------------
switch ($Option) {
    'Run Flyby11' {
        $exe = Resolve-FlybyExe
        if (-not $exe) { throw "Flyby11.exe not found. Place the exe in the scripts folder." }
        Start-Flyby -exePath $exe -args $ArgsText
        break
    }

    'Check version' {
        $exe = Resolve-FlybyExe
        if (-not $exe) { Write-Output "Flyby11.exe not found." ; break }
        $ver = Get-FileVersion -path $exe
        Write-Output "Flyby11 found: $exe"
        Write-Output "File version: $ver"
        break
    }

    'Open exe folder' {
        $exe = Resolve-FlybyExe
        if (-not $exe) { Write-Output "Flyby11.exe not found." ; break }
        $folder = Split-Path -Parent $exe
        Write-Output "Opening folder: $folder"
        Start-Process explorer.exe -ArgumentList $folder
        break
    }

    'Open Releases page' {
        $url = 'https://github.com/builtbybel/FlyOOBE/releases'
        Write-Output "Opening Releases page: $url"
        Open-Url -url $url
        break
    }

    'Help' {
        Show-Help
        break
    }

    default {
        # If user provided only raw args (no option) -> treat as run
        if (-not [string]::IsNullOrWhiteSpace($ArgsText) -and [string]::IsNullOrWhiteSpace($Option)) {
            $exe = Resolve-FlybyExe
            if (-not $exe) { throw "Flyby11.exe not found. Place the exe in the scripts folder." }
            Start-Flyby -exePath $exe -args $ArgsText
            break
        }

        throw "Unknown option. Use 'Help' for usage."
    }
}
