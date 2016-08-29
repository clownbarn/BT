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
            Show-InfoMessage "siteName: mohawkflooring for Mohawk Flooring (Residential)"
            Show-InfoMessage "siteName: mohawksoa for Mohawk Services (SOA)"
            Show-InfoMessage "siteName: mohawkcommercial for Mohawk Commercial (TMG/Commercial)"
            Show-InfoMessage "siteName: mohawkgroup Mohawk Commercial Website (Redesign)"
            Show-InfoMessage "siteName: karastan for Karastan Website"
            Show-InfoMessage "siteName: rrts for Residential Ready To Ship Website"
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
            $dependencySourceDirs = @()
            $dependencyDestDir = ""
            $nugetPackageConfigs = @()
            $BUILD_FAILED = "BUILD FAILED"

            switch($siteName) {
                
                "mohawkflooring" {                     
                    
                    Show-InfoMessage "Starting Mohawk Flooring (Residential) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk"
                    $solutionDir = $projectDirRoot + "\MohawkFlooring"
                    $solutionName = "MohawkFlooring.sln"
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                    $dependencyDestDir = $solutionDir + "\Dependencies"
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
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net35\bin\Debug")
                    $dependencyDestDir = $solutionDir + "\Dependencies"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "mohawkgroup" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commercial Website (Redesign) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-group-website"
                    $solutionDir = $projectDirRoot + "\dotnet"
                    $solutionName = "Mohawk.Commercial.Website.sln"
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                    $dependencyDestDir = $solutionDir + "\dependencies\Mohawk SOA"
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
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                    $dependencyDestDir = $solutionDir + "\dependencies\Mohawk SOA"
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
                    $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                    $dependencyDestDir = $solutionDir + "\Dependencies"
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

            # Third, copy dependencies, if necessary.
            if($dependencySourceDirs.length -ne 0) {

                Show-InfoMessage "Copying dependencies..."

                foreach ($dependencyPath in $dependencySourceDirs) {
                    Show-InfoMessage "Copying path contents from $dependencyPath to $dependencyDestDir"
                    Invoke-Expression ("robocopy " + $dependencyPath + " " + $dependencyDestDir + " /XF *.config *.xml")
                }

                Show-InfoMessage "Dependency copy step complete."
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

            # Fifth, build solution (debug for now).
            Show-InfoMessage "Building solution..."
            Invoke-Expression ("devenv " + $solutionName + " /build debug")

            if($LASTEXITCODE -or !$?) {
                            
                throw $BUILD_FAILED
            }

            Show-InfoMessage "Solution build complete."
            
            # Sixth, do the grunt build, if necessary.
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