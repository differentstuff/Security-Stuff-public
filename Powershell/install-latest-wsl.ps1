#Requires -RunAsAdministrator

# This script helps installing WSL without using the Windows Store in different Variants.
#
# Sources: https://learn.microsoft.com/en-us/windows/wsl/install-manual
# Sources: https://github.com/nandortoth/wsl2-distro-init
# Sources: https://gist.github.com/sanyer/399dd0c3ff304a8e765ca489fa93daa4



<# Variant 1

> To update to WSL 2, you must be running Windows 10... For x64 systems: Version 1903 or later, with Build 18362.1049 or later.

# Enable WSL Feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine feature
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Download the Linux kernel update package
https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

# Set WSL 2 as your default version
wsl --set-default-version 2

#>



<# Variant 2

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$release = Invoke-WebRequest -uri 'https://api.github.com/repos/microsoft/WSL/releases/latest' -UseBasicParsing | ConvertFrom-Json
$systeminfo = [Environment]::Is64BitOperatingSystem
if ($systeminfo -eq $true)
{
    $target = '.x64.msi'
} else
{
    $target = '.arm64.msi'
}

[array]$assets = $release.assets | Where-Object { $_.name.ToLower().endswith('.x64.msi')}
if ($assets.count -ne 1)
{
    throw 'Failed to find asset ($assets)'
}

$targetExe = "C:\temp\$($assets.name)"
Write-Host "Downloading $($assets.name) to $targetExe"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add('Accept','application/octet-stream')

Invoke-WebRequest $assets.url -Out $targetExe -Headers $headers

$MSIArguments = @(
    "/i"
    $targetExe
    "/qn"
    "/norestart"
)

$exitCode = (Start-Process -Wait "msiexec.exe" -ArgumentList $MSIArguments -NoNewWindow -PassThru).ExitCode
if ($exitCode -Ne 0)
{
    throw "Failed to install package: $exitCode"
}

Write-Host 'Installation complete'

Remove-Item $targetExe -Force

#>



<# Variant 3

# Windows now supports a simple WSL installation using the command:
wsl --install

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform

Set-Location -Path "$env:TEMP"

Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile 'wsl_update_x64.msi' -UseBasicParsing
Start-Process 'msiexec.exe' -Wait -ArgumentList '/I wsl_update_x64.msi /quiet'
Remove-Item -Path 'wsl_update_x64.msi'
wsl --set-default-version 2


$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

$WslDistName = 'ubuntu2204'
$WslDistFullName = 'Ubuntu-22.04'
$WslDistUrl = 'https://aka.ms/wslubuntu2204'
$WslDistExe = 'ubuntu2204.exe'
$WslParentDir = 'C:\Temp'
$WslDistPath = Join-Path -Path $WslParentDir -ChildPath $WslDistName

Set-Location -Path $WslParentDir

wsl --set-default-version 2

Invoke-WebRequest -Uri "$WslDistUrl" -OutFile "$WslDistName.appx" -UseBasicParsing
Rename-Item -Path "$WslDistName.appx" -NewName "$WslDistName.zip"
Expand-Archive -Path "$WslDistName.zip" -DestinationPath "$WslDistName"
Remove-Item -Path "$WslDistName.zip"

$userenv = [System.Environment]::GetEnvironmentVariable("PATH", "User")
[System.Environment]::SetEnvironmentVariable("PATH", "$userenv;$WslDistPath", "User")

Start-Process "cmd.exe" -Wait -ArgumentList "echo /c $(Join-Path -Path "$WslDistPath" -ChildPath "$WslDistExe")"
wsl --set-version $WslDistFullName 2
wsl --list --verbose

#>
