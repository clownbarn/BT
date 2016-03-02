Function Start-BuildMohawk
{    
    Process
    {
        Show-InfoMessage "Starting Mohawk Build"

        Start-SiteBuild -siteName mohawksoa

        Start-SiteBuild -siteName mohawkflooring

        Start-SiteBuild -siteName mohawkcommercial
        
        Show-InfoMessage "Mohawk Build Complete"        
    }
}