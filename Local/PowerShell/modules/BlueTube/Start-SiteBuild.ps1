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
            Show-InfoMessage "siteName: soa for Mohawk Services (SOA)"
            Show-InfoMessage "siteName: sitecoreshell for Mohawk Sitecore Shell"
            Show-InfoMessage "siteName: flooring for Mohawk Flooring Website (Redesign)"
            Show-InfoMessage "siteName: flooringlegacy for Mohawk Flooring Website (Legacy)"
            Show-InfoMessage "siteName: tmg Mohawk Commercial Website (Redesign)"
            Show-InfoMessage "siteName: tmglegacy for Mohawk Commercial Website (Legacy)"
            Show-InfoMessage "siteName: rrts for Residential Ready To Ship Website"
            Show-InfoMessage "siteName: rts for Commercial Ready To Ship Website"            
            Show-InfoMessage "siteName: viz for Mohawk Product Visualizer"
            Show-InfoMessage "siteName: bmf for BMF/Portico Website"
            Show-InfoMessage "siteName: aladdin for Aladdin Commercial Website"

            Show-InfoMessage "buildConfig: debug or release"
        }
    }
    Process {

        try {

            $currentDir = (Get-Item -Path ".\" -Verbose).FullName
            $workingDirRoot = if(![string]::IsNullOrEmpty($env:BTPROJPATH)) { $env:BTPROJPATH } else { "C:\BlueTube\Projects\" }
            $sitecoreWorkingDirRoot = if(![string]::IsNullOrEmpty($env:MOHAWKSITECOREPROJPATH)) { $env:MOHAWKSITECOREPROJPATH } else { "C:\mss\" }
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
                
                "flooringlegacy" {                     
                    
                    Show-InfoMessage "Starting Mohawk Flooring (Legacy) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk"
                    $solutionDir = $projectDirRoot + "\MohawkFlooring"
                    $solutionName = "MohawkFlooring.sln"
                    $gruntDir = $projectDirRoot + "\PresentationLayer"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "soa" {                     
                    
                    Show-InfoMessage "Starting Mohawk Services (SOA) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-group-soa"
                    $solutionDir = $projectDirRoot + "\dotnet"
                    $solutionName = "Mohawk.Services.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "tmglegacy" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commercial Website (Legacy) solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-group"
                    $solutionDir = $projectDirRoot + "\projects\TMG\trunk"
                    $solutionName = "TMG.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "sitecoreshell" {
                    
                    Show-InfoMessage "Starting Mohawk Sitecore Shell solution build..."
                    
                    $projectDirRoot = $sitecoreWorkingDirRoot #+ "dotNet\Mohawk.SitecoreShell.Framework"
                    $solutionDir = $sitecoreWorkingDirRoot
                    $solutionName = "Mohawk.SitecoreShell.Website.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break
                }

                "tmg" {                     
                    
                    Show-InfoMessage "Starting Mohawk Commercial Website (Redesign) solution build..."

                    $projectDirRoot = $sitecoreWorkingDirRoot + "inetpub\Mohawk.SitecoreShell.Website\Areas\MohawkGroup"
                    $solutionDir = $projectDirRoot
                    $solutionName = "Mohawk.Commercial.Website.sln"
                    $gulpDir = $projectDirRoot + "\PresentationLayer"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

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

                "viz" {
                    
                    Show-InfoMessage "Starting Mohawk Product Visualizer solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-product-visualization"
                    $solutionDir = $projectDirRoot  
                    $solutionName = "FlooringInstallMethodGenerator.sln"
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break
                }

                "flooring" {                     
                    
                    Show-InfoMessage "Starting Mohawk Flooring Website (Conversion) solution build..."

                    $projectDirRoot = $sitecoreWorkingDirRoot + "inetpub\Mohawk.SitecoreShell.Website\Areas\MohawkFlooring"
                    $solutionDir = $projectDirRoot
                    $solutionName = "Mohawk.Flooring.Sitecore.sln"
                    $gulpDir = $projectDirRoot + "\PresentationLayer"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "bmf" {                     
                    
                    Show-InfoMessage "Starting BMF/Portico Website solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-bmf"
                    $solutionDir = $projectDirRoot
                    $solutionName = "Mohawk.BMF.sln"
                    $gulpDir = $projectDirRoot + "\inetpub\Mohawk.BMF.Website\PresLayerBmf"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }

                "aladdin" {                     
                    
                    Show-InfoMessage "Starting Aladdin Commercial Website solution build..."

                    $projectDirRoot = $workingDirRoot + "mohawk-aladdin-commercial"
                    $solutionDir = $projectDirRoot
                    $solutionName = "Mohawk.AladdinCommercial.sln"
                    $gulpDir = $projectDirRoot + "\inetpub\Mohawk.AladdinCommercial.Website\PresLayerAc"                              
                    $packageDir = $solutionDir + "\packages"

                    $doPreDeployStep = $FALSE

                    break                    
                }
                        
                default {

                    Show-InfoMessage ("Invalid Site Name! " + $siteName)
                    Show-Usage
                    return
                }
            }

            Set-Location $solutionDir
        
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
            if($siteName -ne "soa" -and $siteName -ne "sitecoreshell" -and $siteName -ne "viz")
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

                Set-Location $gruntDir

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

                Set-Location $gulpDir

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

            Set-Location $currentDir
        }
    }
}