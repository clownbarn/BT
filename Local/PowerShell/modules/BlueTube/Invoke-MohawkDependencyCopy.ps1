Function Invoke-MohawkDependencyCopy {
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
        
            Show-InfoMessage "Usage: Invoke-MohawkDependencyCopy -siteName [siteName]"  
            Show-InfoMessage "siteName: mohawkflooring for Mohawk Flooring (Residential)"
            Show-InfoMessage "siteName: mohawkcommercial for Mohawk Commercial (TMG/Commercial)"
            Show-InfoMessage "siteName: mohawkgroup Mohawk Commercial Website (Redesign)"
            Show-InfoMessage "siteName: karastan for Karastan Website"
            Show-InfoMessage "siteName: rrts for Residential Ready To Ship Website"
            Show-InfoMessage "siteName: rts for Commerical Ready To Ship Website"
        }
    }
    Process {                    
            
        $currentDir = (Get-Item -Path ".\" -Verbose).FullName
        $workingDirRoot = if(![string]::IsNullOrEmpty($env:BTPROJPATH)) { $env:BTPROJPATH } else { "C:\BlueTube\Projects\" }
        $projectDirRoot = ""
        $solutionDir = ""
        $dependencySourceDirs = @()
        $dependencyDestDir = ""

        switch($siteName) {
                
            "mohawkflooring" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Flooring (Residential)..."

                $projectDirRoot = $workingDirRoot + "mohawk"
                $solutionDir = $projectDirRoot + "\MohawkFlooring"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                $dependencyDestDir = $solutionDir + "\Dependencies"

                break                    
            }                

            "mohawkcommercial" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Commercial (TMG/Commercial)..."

                $projectDirRoot = $workingDirRoot + "mohawk-group"
                $solutionDir = $projectDirRoot + "\projects\TMG\trunk"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net35\bin\Debug")
                $dependencyDestDir = $solutionDir + "\Dependencies"
                
                break                    
            }

            "mohawkgroup" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Commercial Website (Redesign)..."

                $projectDirRoot = $workingDirRoot + "mohawk-group-website"
                $solutionDir = $projectDirRoot + "\dotnet"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                $dependencyDestDir = $solutionDir + "\dependencies\Mohawk SOA"
                
                break                    
            }

            "karastan" {                     
                    
                Show-InfoMessage "Getting Dependencies for Karastan..."

                $projectDirRoot = $workingDirRoot + "mohawk-karastan-website"
                $solutionDir = $projectDirRoot + "\dotnet"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                $dependencyDestDir = $solutionDir + "\dependencies\Mohawk SOA"
                
                break                    
            }

            "rrts" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Residential Ready To Ship..."

                $projectDirRoot = $workingDirRoot + "mohawk-residential-ready-to-ship"
                $solutionDir = $projectDirRoot + "\dotnet"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
                $dependencyDestDir = $solutionDir + "\Dependencies"
                
                break                    
            }

            "rts" {                     
                    
                Show-InfoMessage "Getting Dependencies for Mohawk Commerical Ready To Ship..."

                $projectDirRoot = $workingDirRoot + "mohawk-ready-to-ship"
                $solutionDir = $projectDirRoot + "\dotnet"
                $dependencySourceDirs = @($workingDirRoot + "mohawk-group-soa\dotNet\Mohawk.Services.Client.Net45\bin\Debug")
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
        Start-SiteBuild -siteName mohawksoa

        # Step 2, copy dependencies
        if($dependencySourceDirs.length -ne 0) {

            Show-InfoMessage "Copying dependencies..."

            foreach ($dependencyPath in $dependencySourceDirs) {
                Show-InfoMessage "Copying path contents from $dependencyPath to $dependencyDestDir"
                Invoke-Expression ("robocopy " + $dependencyPath + " " + $dependencyDestDir + " /XF *.config *.xml")
            }

            Show-InfoMessage "Dependency copy step complete."
        }
    }        
    
}