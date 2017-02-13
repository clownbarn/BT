Function Invoke-MohawkDependencyCopy {
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
        
            Show-InfoMessage "Usage: Invoke-MohawkDependencyCopy -siteName [siteName] -buildConfig [buildConfig]"  
            Show-InfoMessage "siteName: mohawkflooring for Mohawk Flooring (Residential)"
            Show-InfoMessage "siteName: mohawkgroup Mohawk Commercial Website (Redesign)"
            Show-InfoMessage "siteName: rrts for Residential Ready To Ship Website"
            Show-InfoMessage "siteName: rts for Commerical Ready To Ship Website"
            Show-InfoMessage "siteName: tmg for Mohawk Commercial (TMG/Commercial)"

            Show-InfoMessage "buildConfig: debug or release"
        }
    }
    Process {                    
            
        $currentDir = (Get-Item -Path ".\" -Verbose).FullName
        $workingDirRoot = if(![string]::IsNullOrEmpty($env:BTPROJPATH)) { $env:BTPROJPATH } else { "C:\BlueTube\Projects\" }
        $sitecoreWorkingDirRoot = if(![string]::IsNullOrEmpty($env:MOHAWKSITECOREPROJPATH)) { $env:MOHAWKSITECOREPROJPATH } else { "C:\mss\" }
        $projectDirRoot = ""
        $solutionDir = ""
        $dependencySourceDirs = @()
        $dependencyDestDir = ""

        switch($siteName) {
                
            "mohawkflooring" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Flooring (Residential)..."

                $projectDirRoot = $workingDirRoot + "mohawk"
                $solutionDir = $projectDirRoot + "\MohawkFlooring"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\" + $buildConfig)
                $dependencyDestDir = $solutionDir + "\Dependencies"

                break                    
            }                

            "tmg" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Commercial (TMG/Commercial)..."

                $projectDirRoot = $workingDirRoot + "mohawk-group"
                $solutionDir = $projectDirRoot + "\projects\TMG\trunk"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net35\bin\" + $buildConfig)
                $dependencyDestDir = $solutionDir + "\Dependencies"
                
                break                    
            }

            "mohawkgroup" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Commercial Website (Redesign)..."

                $projectDirRoot = $sitecoreWorkingDirRoot + "inetpub\Mohawk.SitecoreShell.Website\Areas\MohawkGroup"
                $solutionDir = $projectDirRoot
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.MohawkGroup\bin\" + $buildConfig)
                $dependencyDestDir = $solutionDir + "\dotNet\dependencies\Mohawk SOA"
                                
                break                    
            }            

            "rrts" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Residential Ready To Ship..."

                $projectDirRoot = $workingDirRoot + "mohawk-residential-ready-to-ship"
                $solutionDir = $projectDirRoot + "\dotnet"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\" + $buildConfig)
                $dependencyDestDir = $solutionDir + "\Dependencies"
                
                break                    
            }

            "rts" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Commerical Ready To Ship..."

                $projectDirRoot = $workingDirRoot + "mohawk-ready-to-ship"
                $solutionDir = $projectDirRoot + "\dotnet"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\"  + $buildConfig)
                $dependencyDestDir = $solutionDir + "\Dependencies"
                
                break                    
            }
                        
            default {

                Show-InfoMessage "Invalid Site Name!"
                Show-Usage
                return
            }
        }

        # Step 1: Build SOA
        Start-SiteBuild -siteName mohawksoa -buildConfig $buildConfig

        # Step 2, copy dependencies
        if($dependencySourceDirs.length -ne 0) {

            Show-InfoMessage "Copying dependencies..."

            foreach ($dependencyPath in $dependencySourceDirs) {
                Show-InfoMessage "Copying path contents from $dependencyPath to $dependencyDestDir"
                Invoke-Expression ("robocopy " + $dependencyPath + " " + '$dependencyDestDir' + " /XF *.config *.xml")
            }

            Show-InfoMessage "Dependency copy step complete."
        }
    }        
    
}