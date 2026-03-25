@echo off
:: This launches PowerShell in a hidden window
powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%~dp0ClearGPUSilent.ps1"
exit