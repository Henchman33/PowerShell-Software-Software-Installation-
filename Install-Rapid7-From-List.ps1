<#
.SYNOPSIS
    Installs software remotely on a list of computers using a .CMD installer from a shared UNC path.
.DESCRIPTION
    Reads computer names from C:\Temp\SoftwareInstall.txt, runs a remote installation command,
    and logs results for success/failure.
#>

# ===== Configuration =====
$ComputerListPath = "C:\Temp\SoftwareInstall.txt"   # List of target computers
$InstallerUNCPath = "E:\Temp\Rapid7\install.cmd"  # Path to the .cmd installer
$LogPath = "C:\Temp\SoftwareInstall_Log.txt"        # Log file location

# ===== Validation =====
If (!(Test-Path $ComputerListPath)) {
    Write-Host "❌ Computer list not found at $ComputerListPath"
    Exit
}
If (!(Test-Path $InstallerUNCPath)) {
    Write-Host "❌ Installer file not found at $InstallerUNCPath"
    Exit
}

# ===== Execution =====
$Computers = Get-Content $ComputerListPath

foreach ($Computer in $Computers) {
    $Computer = $Computer.Trim()
    If ([string]::IsNullOrWhiteSpace($Computer)) { continue }

    Write-Host "🔹 Installing on $Computer ..."
    Try {
        # Execute remotely via Invoke-Command (requires PS Remoting enabled)
        Invoke-Command -ComputerName $Computer -ScriptBlock {
            param($InstallerUNCPath)
            Start-Process -FilePath $InstallerUNCPath -Wait -NoNewWindow
        } -ArgumentList $InstallerUNCPath -ErrorAction Stop

        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') SUCCESS: $Computer - Installation completed."
        Write-Host $Message -ForegroundColor Green
    }
    Catch {
        $Message = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ERROR: $Computer - $($_.Exception.Message)"
        Write-Host $Message -ForegroundColor Red
    }
    Add-Content -Path $LogPath -Value $Message
}

Write-Host "✅ Installation process completed. Check log: $LogPath"
