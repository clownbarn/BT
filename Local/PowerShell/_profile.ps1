# Add custom modules to poweshell module path and import them
$workingDirRoot = if(![string]::IsNullOrEmpty($env:TOOLSPATH)) { $env:TOOLSPATH } else { "C:\Tools\Bin\" }
$modulePath = $workingDirRoot + "BT\PowerShell\modules"
$env:PSModulePath = $env:PSModulePath + ";$($modulePath)"
Import-Module BlueTube -verbose

# Set root working directory, i.e. C:\tools\Bin\
Set-Location $workingDirRoot

# Load WinSCP .NET assembly
Add-Type -Path "$($workingDirRoot)WinSCPnet.dll"