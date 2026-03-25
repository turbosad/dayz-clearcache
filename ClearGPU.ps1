if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
$LogPath = "$env:USERPROFILE\Desktop\GPU_Cleanup_Log.txt"
"--- Cleanup Log Started: $(Get-Date) ---" | Out-File -FilePath $LogPath
function Write-Step ($Message, $Color = "White") {
    $timestamp = Get-Date -Format "HH:mm:ss"; "[$timestamp] $Message" | Out-File -FilePath $LogPath -Append
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}
$Paths = @("$env:LocalAppData\D3DSCache", "$env:LocalAppData\NVIDIA\GLCache", "$env:LocalAppData\NVIDIA\DXCache", "$env:LocalAppData\AMD\DXCache", "$env:ProgramData\NVIDIA Corporation\NV_Cache", "$env:TEMP", "C:\Windows\Temp", "C:\Windows\Prefetch")
try {
    $nv = Get-Service "NVDisplay.ContainerLocalSystem" -ErrorAction SilentlyContinue
    if ($nv -and $nv.Status -eq 'Running') { Write-Step "Stopping NVIDIA Container Service..." "Yellow"; Stop-Service "NVDisplay.ContainerLocalSystem" -Force }
    foreach ($P in $Paths) {
        if (Test-Path $P) {
            Write-Step "Cleaning: $P" "Cyan"
            try { Get-ChildItem -Path $P -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue; Write-Step "  -> Success." "Green" }
            catch { Write-Step "  -> Files in use (Skipped)." "Gray" }
        }
    }
    if ($nv) { Write-Step "Restarting NVIDIA Container Service..." "Yellow"; Start-Service "NVDisplay.ContainerLocalSystem" }
    Write-Step "DONE: All available caches cleared." "Green"
} catch { Write-Step "CRITICAL ERROR: $($_.Exception.Message)" "Red" }
Write-Host "`nPress any key to close..."; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")