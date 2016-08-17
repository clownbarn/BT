Function Invoke-PrepRemoteDebug {
    [cmdletbinding()]
    Param(        
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$siteName        
    )            
    Begin {
        
        <#
            Helper function to show usage of cmdlet.
        #>
        Function Show-Usage {
        
            Show-InfoMessage "Usage: Invoke-PrepRemoteDebug -siteName [siteName]"  
            Show-InfoMessage "siteName: mohawksoa for Mohawk Services (SOA)"            
        }
    }
    Process {
        
        $mohawkSubstSymbolPath = if(![string]::IsNullOrEmpty($env:MOHAWKSUBSTSYMBOLPATH)) { $env:MOHAWKSUBSTSYMBOLPATH } else { "C:\stuff\octopus" } #leave trailing backslash off here, or SUBST will fail.

        $projectDirRoot = if(![string]::IsNullOrEmpty($env:BTPROJPATH)) { $env:BTPROJPATH } else { "C:\BlueTube\Projects\" }
        $projectPath = ""
        $projectOutputAssembly = ""
        $projecOutputSymbolFile = ""
        $mohawkSymbolPath = ""

        switch($siteName) {
                
                "mohawksoa" {                     
                    
                    #Show-InfoMessage "Starting Mohawk Services (SOA) solution build..."

                    $projectPath = $projectDirRoot + "mohawk-group-soa\inetpub\Mohawk.Services\"
                    $projectOutputAssembly = "Mohawk.Services.dll"
                    $projecOutputSymbolFile = "Mohawk.Services.pdb"
                    $mohawkSymbolPath = "E:\BuildAgent\work\41940996df7cf9db\inetpub\Mohawk.Services\"
                    
                    break                    
                }

                default {

                    Show-InfoMessage "Invalid Site Name!"
                    Show-Usage
                    return
                }
        }        

        Invoke-Expression "SUBST E: $($mohawkSubstSymbolPath)"

        Invoke-Expression "RoboCopy $($projectPath) $($mohawkSymbolPath) *.cs /e /LOG+:$($mohawkSymbolPath)\robocopy.log"
        Invoke-Expression "RoboCopy $($projectPath) $($mohawkSymbolPath) *.cshtml /e /LOG+:$($mohawkSymbolPath)\robocopy.log"
        Invoke-Expression "del $($mohawkSymbolPath)\obj\Release\*.*"

        Invoke-Expression "copy $($mohawkSymbolPath)\bin\$($projectOutputAssembly) $($mohawkSymbolPath)\obj\Release\$($projectOutputAssembly)"
        Invoke-Expression "copy $($mohawkSymbolPath)\bin\$($projecOutputSymbolFile) $($mohawkSymbolPath)\obj\Release\$($projecOutputSymbolFile)"
    }
}