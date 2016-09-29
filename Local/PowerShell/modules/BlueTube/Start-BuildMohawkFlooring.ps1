Function Start-BuildMohawkFlooring
{    
    Process
    {
        Show-InfoMessage "Starting Mohawk Flooring Website Build..."

        Start-SiteBuild -siteName mohawksoa

        Start-SiteBuild -siteName mohawkflooring
                
        Show-InfoMessage "Mohawk Flooring Website Build Complete."        
    }
}