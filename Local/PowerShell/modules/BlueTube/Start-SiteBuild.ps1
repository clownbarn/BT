Function Start-SiteBuild {
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
        
            Show-InfoMessage "Usage: Start-SiteBuild -siteName [siteName]"  
            Show-InfoMessage "siteName: lyric for Lyric Opera of Chicago"
            Show-InfoMessage "siteName: voices for Chicago Voices"
        }
    }
    Process {

        $currentDir = (Get-Item -Path ".\" -Verbose).FullName
        $workingDirRoot = "C:\BlueTube\Projects\Clients\"
        $workingDir = ""
        $solutionName = ""

        switch($siteName) {

            "lyric" {                     

                $workingDir = $workingDirRoot + "lyric-opera-of-chicago\dotnet"
                $solutionName = "LyricOpera.Website.sln"                                
                break                    
            }

            "voices" {                     

                $workingDir = $workingDirRoot + "lyric-opera-of-chicago\dotnet"
                $solutionName = "LyricOpera.ChicagoVoices.Website.sln"                                
                break                    
            }
                        
            default {

                Show-InfoMessage "Invalid Site Name"
                Show-Usage
                return
            }
        }

        cd $workingDir

        # First, perform a clean.
        Invoke-Expression ("devenv " + $solutionName + " /clean")

        # Second, build (debug for now).
        Invoke-Expression ("devenv " + $solutionName + " /build debug")

        # Third, re-deploy the Sitecore files.
        Invoke-SitePreDeploy -siteName $siteName

        cd $currentDir
    }
}