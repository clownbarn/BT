Function Start-BuildRTS
{    
    Process
    {
        Show-InfoMessage "Starting Mohawk Commercial Ready To Ship Build"

        Start-SiteBuild -siteName mohawksoa

        Start-SiteBuild -siteName rts
        
        Show-InfoMessage "Mohawk Mohawk Commercial Ready To Ship Build Complete"        
    }
}