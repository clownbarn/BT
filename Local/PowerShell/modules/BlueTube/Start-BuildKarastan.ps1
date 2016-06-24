Function Start-BuildKarastan
{    
    Process
    {
        Show-InfoMessage "Starting Karastan Build..."

        Start-SiteBuild -siteName mohawksoa

        Start-SiteBuild -siteName karastan
        
        Show-InfoMessage "Karastan Build Complete."        
    }
}