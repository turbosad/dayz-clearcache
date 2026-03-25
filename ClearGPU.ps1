# 1. Self-Elevation (Triggers UAC Prompt)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. Setup Logging
$LogPath = "$env:USERPROFILE\Desktop\GPU_Cleanup_Log.txt"
"--- DayZ & GPU Cleanup Started: $(Get-Date) ---" | Out-File -FilePath $LogPath

function Write-Step ($Message, $Color = "White") {
    $timestamp = Get-Date -Format "HH:mm:ss"
    "[$timestamp] $Message" | Out-File -FilePath $LogPath -Append
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

# 3. Target Paths (GPU + DayZ Logs + System Temp)
$Paths = @(
    # GPU Shader Caches
    "$env:LocalAppData\D3DSCache",
    "$env:LocalAppData\NVIDIA\GLCache",
    "$env:LocalAppData\NVIDIA\DXCache",
    "$env:LocalAppData\AMD\DXCache",
    "$env:ProgramData\NVIDIA Corporation\NV_Cache",
    
    # DayZ Specific (Crash dumps .mdmp, logs .RPT, script logs)
    "$env:LocalAppData\DayZ",
    "$env:LocalAppData\DayZ Exp",
    
    # Windows System Temp
    "$env:TEMP",
    "C:\Windows\Temp",
    "C:\Windows\Prefetch"
)

try {
    # 4. Handle NVIDIA Services (Unlocks shader files)
    $nv = Get-Service "NVDisplay.ContainerLocalSystem" -ErrorAction SilentlyContinue
    if ($nv -and $nv.Status -eq 'Running') { 
        Write-Step "Stopping NVIDIA Container Service..." "Yellow"
        Stop-Service "NVDisplay.ContainerLocalSystem" -Force 
    }

    # 5. Execute Cleanup Loop
    foreach ($P in $Paths) {
        if (Test-Path $P) {
            Write-Step "Cleaning: $P" "Cyan"
            try {
                # Get all items inside and delete them
                Get-ChildItem -Path $P -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Write-Step "  -> Success." "Green"
            } catch {
                # This catches files currently locked by the OS or other apps
                Write-Step "  -> Some files in use (Skipped)." "Gray"
            }
        } else {
            Write-Step "  -> Path not found (Skipping): $P" "DarkGray"
        }
    }

    # 6. Restart NVIDIA Services
    if ($nv) { 
        Write-Step "Restarting NVIDIA Container Service..." "Yellow"
        Start-Service "NVDisplay.ContainerLocalSystem" 
    }

    Write-Step "DONE: DayZ logs and GPU caches cleared." "Green"
    Write-Host "`nRecommendation: Press Win+Ctrl+Shift+B now to reset driver stack." -ForegroundColor Magenta

} catch {
    Write-Step "CRITICAL ERROR: $($_.Exception.Message)" "Red"
}

Write-Host "`nPress any key to close..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")