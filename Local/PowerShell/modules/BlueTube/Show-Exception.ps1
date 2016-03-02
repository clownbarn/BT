<#
    Helper function to show exception details.
#>
Function Show-Exception
{
    [cmdletbinding()]
        Param(
            [parameter(Mandatory=$true, ValueFromPipeline)]
            [ValidateNotNullOrEmpty()] #No value
            [Exception]$exception
            )

    Process {
        
        Write-Host (($exception|format-list -force) | Out-String) -ForegroundColor Red
    }
}