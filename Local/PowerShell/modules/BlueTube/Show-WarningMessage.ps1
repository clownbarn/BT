<#
    Helper function to show warning message.
#>
Function Show-WarningMessage
{
    [cmdletbinding()]
        Param(
            [parameter(Mandatory=$true, ValueFromPipeline)]
            [ValidateNotNullOrEmpty()] #No value
            [string]$msg
            )
    
    Process {
        
        Write-Host "WARNING: $($msg)" -ForegroundColor Yellow
    }
}