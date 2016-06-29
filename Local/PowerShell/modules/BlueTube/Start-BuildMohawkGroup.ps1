Function Start-BuildMohawkGroup
{    
    Process
    {
        Show-InfoMessage "Starting Mohawk Commercial Website (Redesign) Build"

        Start-SiteBuild -siteName mohawksoa
                
        Start-SiteBuild -siteName mohawkgroup
        
        Show-InfoMessage "Mohawk Commercial Website (Redesign) Build Complete"        
    }
}