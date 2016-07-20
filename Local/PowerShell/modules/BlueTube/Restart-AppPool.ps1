Function Restart-AppPool {
    
	[cmdletbinding()]
		Param(
			[parameter(Mandatory=$true, ValueFromPipeline)]
			[ValidateNotNullOrEmpty()] #No value
			[string]$appPool
			)
            
	Begin {
        
        <#
            Helper function to show usage of cmdlet.
        #>
        Function Show-Usage {
        
            Show-InfoMessage "Usage: Restart-AppPool -siteName [siteName]"  
            Show-InfoMessage "siteName: mohawkflooring for Mohawk Flooring (Residential)"
            Show-InfoMessage "siteName: mohawksoa for Mohawk Services (SOA)"
            Show-InfoMessage "siteName: mohawkcommercial for Mohawk Commercial (TMG/Commercial)"
            Show-InfoMessage "siteName: mohawkgroup Mohawk Commercial Website (Redesign)"
            Show-InfoMessage "siteName: karastan for Karastan Website"
        }
    }
	Process {
        	
        $site = ""

		switch($appPool)
		{
			"mohawkflooring" {                     
                    
                $site = "dev.mohawkflooring.local"
                break                    
            }

            "mohawksoa" {                     
                    
                $site = "api.mohawk.local"
                break                    
            }

            "mohawkcommercial" {                     
                    
                $site = "dev.mohawkcommercial.local"
                break                    
            }

            "mohawkgroup" {                     
                    
                $site = "dev.mohawkgroup.local"                            
                break                    
            }

            "karastan" {                     
                    
                $site = "dev.karastan.local"                             
                break                    
            }
                        
            default {

                Show-InfoMessage "Invalid Site Name!"
                Show-Usage
                return
            }
		}
        
        Show-InfoMessage "Restarting $($appPool) App Pool..."                               

        Import-Module WebAdministration
        $pool = (Get-Item "IIS:\Sites\$site"| Select-Object applicationPool).applicationPool
        Restart-WebAppPool $pool

        Show-InfoMessage "$($appPool) App Pool Restarted."
    }
}