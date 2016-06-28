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
            Show-InfoMessage "siteName: karastan for Karastan Website"
        }
    }
    Process {

        try {

            $currentDir = (Get-Item -Path ".\" -Verbose).FullName
            $workingDirRoot = if(![string]::IsNullOrEmpty($env:BTPROJPATH)) { $env:BTPROJPATH } else { "C:\BlueTube\Projects\" }
            $workingDir = ""
            $solutionName = ""
            $doPreDeployStep = $FALSE
            $gruntDir = ""
            $gulpDir = ""
            $dependencySourceDirs = @()
            $dependencyDestDir = ""
            $BUILD_FAILED = "BUILD FAILED"

            switch($siteName) {

                "lyric" {                     
                    
                    Show-InfoMessage "Starting Lyric Opera of Chicago solution build..."

                    $workingDir = $workingDirRoot + "lyric-opera-of-chicago\dotnet"
                    $solutionName = "LyricOpera.Website.sln"
                    $doPreDeployStep = $TRUE                                
                    break                    
                }

                "voices" {                     
                    
                    Show-InfoMessage "Starting Chicago Voices solution build..."

                    $workingDir = $workingDirRoot + "lyric-opera-of-chicago-voices\dotnet"
                    $solutionName = "LyricOpera.ChicagoVoices.Website.sln"
                    $doPreDeployStep = $TRUE                                
                    break                    
                }

                "mohawkflooring" {                     
                    
                    Show-InfoMessage "Starting Mohawk Flooring (Residential) solution build..."

                    $workingDir = $workingDirRoot + "mohawk\MohawkFlooring"
                    $solutionName = "MohawkFlooring.sln" 
                    $doPreDeployStep = $FALSE
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                    $dependencyDestDir = $workingDirRoot + "mohawk\MohawkFlooring\Dependencies"
                    $gruntDir = $workingDirRoot + "mohawk\PresentationLayer"                              
                    break                    
                }

                "mohawksoa" {                     
                    
                    Show-InfoMessage "Starting Mohawk Services (SOA) solution build..."

                    $workingDir = $workingDirRoot + "mohawk-group-soa\dotNet"
                    $solutionName = "Mohawk.Services.sln" 
                    $doPreDeployStep = $FALSE
                    break                    
                }

                "mohawkcommercial" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commercial (TMG/Commercial) solution build..."

                    $workingDir = $workingDirRoot + "mohawk-group\projects\TMG\trunk"
                    $solutionName = "TMG.sln"
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net35\bin\Debug")
                    $dependencyDestDir = $workingDirRoot + "mohawk-group\projects\TMG\trunk\Dependencies" 
                    $doPreDeployStep = $FALSE
                    break                    
                }

                "karastan" {                     
                    
                    Show-InfoMessage "Starting Karastan solution build..."

                    $workingDir = $workingDirRoot + "mohawk-karastan-website\dotnet"
                    $solutionName = "Mohawk.Karastan.Website.sln" 
                    $doPreDeployStep = $TRUE
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                    $dependencyDestDir = $workingDirRoot + "mohawk-karastan-website\dotnet\dependencies\Mohawk SOA"
                    $gulpDir = $workingDirRoot + "mohawk-karastan-website\inetpub\PresentationLayer"                              
                    break                    
                }
                        
                default {

                    Show-InfoMessage "Invalid Site Name!"
                    Show-Usage
                    return
                }
            }

            cd $workingDir
        
            # First, perform a clean.
            Show-InfoMessage "Performing clean..."
            Invoke-Expression ("devenv " + $solutionName + " /clean")

            if($LASTEXITCODE -or !$?) {

                throw $BUILD_FAILED
            }

            Show-InfoMessage "Clean complete."
                                                
            # Second, run the PreDeploy step, if necessary.
            if($doPreDeployStep) {

                Show-InfoMessage "Performing PreDeploy step..."
                Invoke-SitePreDeploy -siteName $siteName
                Show-InfoMessage "PreDeploy step complete."
            }            

            # Third, copy dependencies, if necessary.
            if($dependencySourceDirs.length -ne 0) {

                Show-InfoMessage "Copying dependencies..."

                foreach ($dependencyPath in $dependencySourceDirs) {
	                Show-InfoMessage "Copying path contents from $depenencyPath to $dependencyDestDir"
                    Invoke-Expression ("robocopy " + $dependencyPath + " " + $dependencyDestDir + " /XF *.config *.xml")	                
                }

                Show-InfoMessage "Dependency copy step complete."
            }            

            # Fourth, build solution (debug for now).
            Show-InfoMessage "Building solution..."
            Invoke-Expression ("devenv " + $solutionName + " /build debug")

            if($LASTEXITCODE -or !$?) {
                            
                throw $BUILD_FAILED
            }

            Show-InfoMessage "Solution build complete."
            
            # Fifth, do the grunt build, if necessary.
            if(![string]::IsNullOrEmpty($gruntDir)) {
                
                Show-InfoMessage "Performing Grunt build step..."

                cd $gruntDir

                Invoke-Expression ("grunt build")

                if($LASTEXITCODE -or !$?) {

                    throw $BUILD_FAILED
                } 
                
                Invoke-Expression ("grunt copyassets")

                if($LASTEXITCODE -or !$?) {

                    throw $BUILD_FAILED
                }
                Show-InfoMessage "Grunt build step complete."
            }
            
            # Sixth, do the gulp build, if necessary.
            if(![string]::IsNullOrEmpty($gulpDir)) {
                
                Show-InfoMessage "Performing Gulp build step..."

                cd $gulpDir

                Invoke-Expression ("gulp build")

                if($LASTEXITCODE -or !$?) {

                    throw $BUILD_FAILED
                } 

                Show-InfoMessage "Gulp build step complete."
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