Function Invoke-SitePreDeploy {
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
        
            Show-InfoMessage "Usage: Invove-SitePreDeploy -siteName [siteName]"  
            Show-InfoMessage "siteName: lyric for Lyric Opera of Chicago"
            Show-InfoMessage "siteName: voices for Chicago Voices"
        }
    }
    Process {
        
        $currentDir = (Get-Item -Path ".\" -Verbose).FullName
        $workingDirRoot = "C:\BlueTube\Projects\Clients\"
        $workingDir = ""

        switch($siteName) {

            "lyric" {                     

                $workingDir = $workingDirRoot + "lyric-opera-of-chicago\inetpub\LyricOpera.Website"                
                break                    
            }

            "voices" {                     

                $workingDir = $workingDirRoot + "lyric-opera-of-chicago-voices\inetpub\LyricOpera.ChicagoVoices.Website"                
                break                    
            }

            "mohawkflooring" {                     

                $workingDir = $workingDirRoot + "Mohawk Industries\mohawk\MohawkFlooring\MohawkFlooring.UI"                
                break                    
            }
                        
            default {

                Show-InfoMessage "Invalid Site Name"
                Show-Usage
                return
            }
        }

        cd $workingDir

        . $workingDir\PreDeploy.ps1

        cd $currentDir
    }
}