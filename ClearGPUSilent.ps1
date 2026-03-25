# 1. Self-Elevation (Silent)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# 2. Setup Logging
$LogPath = "$env:USERPROFILE\Desktop\GPU_Cleanup_Log.txt"
"--- Silent Cleanup Started: $(Get-Date) ---" | Out-File -FilePath $LogPath

# 3. Target Paths
$Paths = @(
    "$env:LocalAppData\D3DSCache",
    "$env:LocalAppData\NVIDIA\GLCache",
    "$env:LocalAppData\NVIDIA\DXCache",
    "$env:LocalAppData\AMD\DXCache",
    "$env:ProgramData\NVIDIA Corporation\NV_Cache",
    "$env:TEMP",
    "C:\Windows\Temp",
    "C:\Windows\Prefetch"
)

try {
    # 4. Handle Services
    $nv = Get-Service "NVDisplay.ContainerLocalSystem" -ErrorAction SilentlyContinue
    if ($nv -and $nv.Status -eq 'Running') { 
        Stop-Service "NVDisplay.ContainerLocalSystem" -Force -ErrorAction SilentlyContinue
    }

    # 5. Silent Wipe
    foreach ($P in $Paths) {
        if (Test-Path $P) {
            Get-ChildItem -Path $P -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # 6. Restart Services
    if ($nv) { 
        Start-Service "NVDisplay.ContainerLocalSystem" -ErrorAction SilentlyContinue
    }

    "DONE: Silent cleanup finished at $(Get-Date)" | Out-File -FilePath $LogPath -Append
} catch {
    "CRITICAL ERROR: $($_.Exception.Message)" | Out-File -FilePath $LogPath -Append
}