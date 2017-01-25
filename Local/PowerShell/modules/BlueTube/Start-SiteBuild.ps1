Function Start-SiteBuild {
    [cmdletbinding()]
    Param(        
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$siteName,
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$buildConfig        
    )
    Begin {
        
        <#
            Helper function to show usage of cmdlet.
        #>
        Function Show-Usage {
        
            Show-InfoMessage "Usage: Start-SiteBuild -siteName [siteName] -buildConfig [buildConfig]"  
            Show-InfoMessage "siteName: mohawkflooring for Mohawk Flooring (Residential)"
            Show-InfoMessage "siteName: mohawksoa for Mohawk Services (SOA)"
            Show-InfoMessage "siteName: mohawkcommercial for Mohawk Commercial (TMG/Commercial)"
            Show-InfoMessage "siteName: mohawkgroup Mohawk Commercial Website (Redesign)"
            Show-InfoMessage "siteName: karastan for Karastan Website"
            Show-InfoMessage "siteName: rrts for Residential Ready To Ship Website"
            Show-InfoMessage "siteName: rts for Commerical Ready To Ship Website"

            Show-InfoMessage "buildConfig: debug or release"
        }
    }
    Process {

        try {

            $currentDir = (Get-Item -Path ".\" -Verbose).FullName
            $workingDirRoot = if(![string]::IsNullOrEmpty($env:BTPROJPATH)) { $env:BTPROJPATH } else { "C:\BlueTube\Projects\" }
            $projectDirRoot = ""
            $solutionDir = ""
            $solutionName = ""
            $packageDir = ""
            $doPreDeployStep = $FALSE
            $gruntDir = ""
            $gulpDir = ""
            $nugetPackageConfigs = @()
            $BUILD_FAILED = "BUILD FAILED"

            switch($siteName) {
                
                "mohawkflooring" {                     
                    
                    Show-InfoMessage "Starting Mohawk Flooring (Residential) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk"
                    $solutionDir = $projectDirRoot + "\MohawkFlooring"
                    $solutionName = "MohawkFlooring.sln"
                    $gruntDir = $projectDirRoot + "\PresentationLayer"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "mohawksoa" {                     
                    
                    Show-InfoMessage "Starting Mohawk Services (SOA) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-group-soa"
                    $solutionDir = $projectDirRoot + "\dotnet"
                    $solutionName = "Mohawk.Services.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "mohawkcommercial" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commercial (TMG/Commercial) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-group"
                    $solutionDir = $projectDirRoot + "\projects\TMG\trunk"
                    $solutionName = "TMG.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "mohawkgroup" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commercial Website (Redesign) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-group-website"
                    $solutionDir = $projectDirRoot + "\dotnet"
                    $solutionName = "Mohawk.Commercial.Website.sln"
                    $gulpDir = $projectDirRoot + "\inetpub\PresentationLayer"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $TRUE

                    break                    
                }

                "karastan" {                     
                    
                    Show-InfoMessage "Starting Karastan solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-karastan-website"
                    $solutionDir = $projectDirRoot + "\dotnet"
                    $solutionName = "Mohawk.Karastan.Website.sln"
                    $gulpDir = $projectDirRoot + "\inetpub\PresentationLayer"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $TRUE

                    break                    
                }

                "rrts" {                     
                    
                    Show-InfoMessage "Starting Mohawk Residential Ready To Ship solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-residential-ready-to-ship"
                    $solutionDir = $projectDirRoot + "\dotnet"
                    $solutionName = "Mohawk.Residential.ReadyToShip.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "rts" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commerical Ready To Ship solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-ready-to-ship"
                    $solutionDir = $projectDirRoot + "\dotnet"
                    $solutionName = "MohawkReadyToShip.Framework.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }
                        
                default {

                    Show-InfoMessage "Invalid Site Name!"
                    Show-Usage
                    return
                }
            }

            cd $solutionDir
        
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

            # Third, copy dependencies, if necessary (Not necessary for SOA itself).
            if($siteName -ne "mohawksoa")
            {
                Invoke-MohawkDependencyCopy -siteName $siteName -buildConfig $buildConfig          
            }

            # Fourth, restore Nuget packages, if necessary.
            $nugetPackageConfigs = Get-ChildItem $projectDirRoot -Filter packages.config -r | Foreach-Object {$_.FullName}

            if($nugetPackageConfigs.length -ne 0) {
                
                Show-InfoMessage "Restoring Nuget packages for solution..."

                foreach ($config in $nugetPackageConfigs) {

                    Show-InfoMessage "Restoring Nuget packages defined in: $($config)"
                    
                    Invoke-Expression ("nuget restore -NonInteractive " + $config + " -PackagesDirectory " + $packageDir + " -MSBuildVersion 14 -Verbosity detailed")

                    if($LASTEXITCODE -or !$?) {
                            
                        throw $BUILD_FAILED
                    }
                }

                Show-InfoMessage "Nuget package restore step complete."
            }            

            # Fifth, build solution.
            Show-InfoMessage "Building solution..."
            Invoke-Expression ("devenv " + $solutionName + " /build " + $buildConfig)

            if($LASTEXITCODE -or !$?) {
                            
                throw $BUILD_FAILED
            }

            Show-InfoMessage "Solution build complete."
            
            # Sixth, do the grunt build, if necessary.
            if(![string]::IsNullOrEmpty($gruntDir)) {
                
                Show-InfoMessage "Performing Grunt build step..."

                cd $gruntDir

                Invoke-Expression ("grunt build:prod --force")

                if($LASTEXITCODE -or !$?) {

                    throw $BUILD_FAILED
                } 
                
                Invoke-Expression ("grunt copyassets")

                if($LASTEXITCODE -or !$?) {

                    throw $BUILD_FAILED
                }
                Show-InfoMessage "Grunt build step complete."
            }
            
            # Seventh, do the gulp build, if necessary.
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