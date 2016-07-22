$workingDirRoot = if(![string]::IsNullOrEmpty($env:TOOLSPATH)) { $env:TOOLSPATH } else { "C:\Tools\Bin\" }
$modulePath = $workingDirRoot + "BT\PowerShell\modules"

$env:PSModulePath = $env:PSModulePath + ";$($modulePath)"

Import-Module BlueTube -verbose

Set-Location $workingDirRoot