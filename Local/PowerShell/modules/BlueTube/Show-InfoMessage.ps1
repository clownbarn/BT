<#
    Helper function to show information message.
#>
Function Show-InfoMessage
{
    [cmdletbinding()]
        Param(
            [parameter(Mandatory=$true, ValueFromPipeline)]
            [ValidateNotNullOrEmpty()] #No value
            [string]$msg
            )
    #Write-Host $msg -ForegroundColor White

    Process {
        
        Write-Host $msg -ForegroundColor White
    }
}