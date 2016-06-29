Function Start-BuildKarastan
{    
    Process
    {
        Show-InfoMessage "Starting Karastan Website Build..."

        Start-SiteBuild -siteName mohawksoa

        Start-SiteBuild -siteName karastan
        
        Show-InfoMessage "Karastan Website Build Complete."        
    }
}