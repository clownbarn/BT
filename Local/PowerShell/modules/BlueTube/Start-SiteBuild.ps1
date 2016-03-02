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
            Show-InfoMessage "siteName: mohawkflooring for Mohawk Flooring (Residential)"
        }
    }
    Process {

        try {

            $currentDir = (Get-Item -Path ".\" -Verbose).FullName
            $workingDirRoot = "C:\BlueTube\Projects\Clients\"
            $workingDir = ""
            $solutionName = ""
            $doPreDeployStep = $FALSE
            $gruntDir = ""
            $BUILD_FAILED = "BUILD FAILED"

            switch($siteName) {

                "lyric" {                     

                    $workingDir = $workingDirRoot + "lyric-opera-of-chicago\dotnet"
                    $solutionName = "LyricOpera.Website.sln"
                    $doPreDeployStep = $TRUE                                
                    break                    
                }

                "voices" {                     

                    $workingDir = $workingDirRoot + "lyric-opera-of-chicago-voices\dotnet"
                    $solutionName = "LyricOpera.ChicagoVoices.Website.sln"
                    $doPreDeployStep = $TRUE                                
                    break                    
                }

                "mohawkflooring" {                     

                    $workingDir = $workingDirRoot + "Mohawk Industries\mohawk\MohawkFlooring"
                    $solutionName = "MohawkFlooring.sln" 
                    $doPreDeployStep = $FALSE
                    $gruntDir = $workingDirRoot + "Mohawk Industries\mohawk\PresentationLayer"                              
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

            if($LASTEXITCODE -or !$?) {

                Show-ErrorMessage $BUILD_FAILED
                return
            }
                                                
            # Second, run the PreDeploy step, if necessary
            if($doPreDeployStep) {

                Invoke-SitePreDeploy -siteName $siteName
            }            

            # Third, build solution (debug for now).
            Invoke-Expression ("devenv " + $solutionName + " /build debug")

            if($LASTEXITCODE -or !$?) {

                Show-ErrorMessage $BUILD_FAILED
                return
            }            
            
            # Fourth, do the grunt build, if necessary
            if(![string]::IsNullOrEmpty($gruntDir)) {

                cd $gruntDir

                Invoke-Expression ("grunt build:prod")

                if($LASTEXITCODE -or !$?) {

                    Show-ErrorMessage $BUILD_FAILED
                    return
                } 
                
                Invoke-Expression ("grunt copyassets")

                if($LASTEXITCODE -or !$?) {

                    Show-ErrorMessage $BUILD_FAILED
                    return
                }
            }        
        }
        catch {
                    
            Show-Exception $_.Exception            
        }
        finally {

            cd $currentDir
        }
    }
}