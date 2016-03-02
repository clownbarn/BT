<#
    Helper function to show error message.
#>
Function Show-ErrorMessage
{
    [cmdletbinding()]
        Param(
            [parameter(Mandatory=$true, ValueFromPipeline)]
            [ValidateNotNullOrEmpty()] #No value
            [string]$msg
            )
    
    Process {
        
        Write-Host $msg -ForegroundColor Red
    }
}