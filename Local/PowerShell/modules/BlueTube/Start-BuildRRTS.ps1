Function Start-BuildRRTS
{    
    Process
    {
        Show-InfoMessage "Starting Mohawk Residential Ready To Ship Build"

        Start-SiteBuild -siteName mohawksoa

        Start-SiteBuild -siteName rrts
        
        Show-InfoMessage "Mohawk Mohawk Residential Ready To Ship Build Complete"        
    }
}