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
            Show-InfoMessage "siteName: mohawksoa for Mohawk Services (SOA)"
            Show-InfoMessage "siteName: mohawkcommercial for Mohawk Commercial (TMG/Commercial)"
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
            $dependencySourceDirs = @()
            $dependencyDestDir = ""
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
                    
                    Show-InfoMessage "Starting Mohawk Flooring (Residential) build..."

                    $workingDir = $workingDirRoot + "Mohawk Industries\mohawk\MohawkFlooring"
                    $solutionName = "MohawkFlooring.sln" 
                    $doPreDeployStep = $FALSE
                    $dependencySourceDirs = @(
	                    $workingDirRoot + "Mohawk Industries\mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                    $dependencyDestDir = $workingDirRoot + "Mohawk Industries\mohawk\MohawkFlooring\Dependencies"
                    $gruntDir = $workingDirRoot + "Mohawk Industries\mohawk\PresentationLayer"                              
                    break                    
                }

                "mohawksoa" {                     
                    
                    Show-InfoMessage "Starting Mohawk Services (SOA) build..."

                    $workingDir = $workingDirRoot + "Mohawk Industries\mohawk-group-soa\dotNet"
                    $solutionName = "Mohawk.Services.sln" 
                    $doPreDeployStep = $FALSE
                    break                    
                }

                "mohawkcommercial" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commercial (TMG/Commercial) build..."

                    $workingDir = $workingDirRoot + "Mohawk Industries\mohawk-group\projects\TMG\trunk"
                    $solutionName = "TMG.sln"
                    $dependencySourceDirs = @(
	                    $workingDirRoot + "Mohawk Industries\mohawk-group-soa\dotNet\Mohawk.Services.Client.Net35\bin\Debug")
                    $dependencyDestDir = $workingDirRoot + "Mohawk Industries\mohawk-group\projects\TMG\trunk\Dependencies" 
                    $doPreDeployStep = $FALSE
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
            Show-InfoMessage "Performing Clean..."
            Invoke-Expression ("devenv " + $solutionName + " /clean")

            if($LASTEXITCODE -or !$?) {

                throw $BUILD_FAILED
            }
            Show-InfoMessage "Clean Complete."
                                                
            # Second, run the PreDeploy step, if necessary.
            if($doPreDeployStep) {

                Show-InfoMessage "Performing PreDeploy step..."
                Invoke-SitePreDeploy -siteName $siteName
                Show-InfoMessage "PreDeploy step complete."
            }            

            # Third, build solution (debug for now).
            Show-InfoMessage "Building solution..."
            Invoke-Expression ("devenv " + $solutionName + " /build debug")

            if($LASTEXITCODE -or !$?) {
                            
                throw $BUILD_FAILED
            }
            Show-InfoMessage "Solution build complete."
            
            # Fourth, copy dependencies, if necessary.
            Show-InfoMessage "Copying dependencies..."
            foreach ($depenencyPath in $dependencySourceDirs) {
	            Show-InfoMessage "Copying path contents from $depenencyPath to $dependencyDestDir"
	            robocopy "$depenencyPath" "$dependencyDestDir"
            }
            Show-InfoMessage "Dependency copy step complete."
            
            # Fifth, do the grunt build, if necessary.
            if(![string]::IsNullOrEmpty($gruntDir)) {
                
                Show-InfoMessage "Performing Grunt build step..."

                cd $gruntDir

                Invoke-Expression ("grunt build:prod")

                if($LASTEXITCODE -or !$?) {

                    throw $BUILD_FAILED
                } 
                
                Invoke-Expression ("grunt copyassets")

                if($LASTEXITCODE -or !$?) {

                    throw $BUILD_FAILED
                }
                Show-InfoMessage "Grunt build step complete."
            }        
        }
        catch {
            
            if($_.Exception.Message -ne $BUILD_FAILED) {    
                Show-Exception $_.Exception
            }

            throw            
        }
        finally {

            cd $currentDir
        }
    }
}