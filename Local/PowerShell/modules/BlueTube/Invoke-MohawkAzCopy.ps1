# Invoke-MohawkAzCopy is a Powershell Cmdlet that copies Azure blobs for Product Spec PDFs,
# Sustainability PDFs, and all PDF Template Assets from one environment to another.
# This script has a dependency on the AzCopy Executable, which must be in the PATH
# Environment Variable where this script is used.
#
# AzCopy can be obtained here: http://aka.ms/downloadazcopy
# 
# Once installed, ensure the executable is in the PATH Environment Variable. The default installation
# path for AzCopy is typically : %PROGRAMFILES(X86)%\Microsoft SDKs\Azure\AzCopy
#
# Example Usage: Mohawk-AzCopy -source DEV -dest QA
#
# Valid values for -source and -dest: HQ, DEV, QA, UAT, and PROD

Function Invoke-MohawkAzCopy {
    [cmdletbinding()]
    Param(        
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$source,  
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$dest      
    )
    Begin {
        
        <#
            Helper function to show usage of cmdlet.
        #>
        function Show-Usage() {
        
            Show-InfoMessage "Usage: Invoke-MohawkAzCopy -source [source] -dest [dest]"
            Show-InfoMessage "Valid values for -source and -dest: HQ, DEV, QA, UAT, and PROD"
        }
    }
    Process {

        $_HQ = "HQ"
        $_DEV = "DEV"
        $_QA = "QA"
        $_UAT = "UAT"
        $_PROD = "PROD"

        # HQ and DEV use the same Azure Blobs, so there is no need to continue. If we did, AzCopy would throw an error anyway.
        if(($source -eq $_HQ -and $dest -eq $_DEV) -or ($source -eq $_DEV -and $dest -eq $_HQ)) {

            Show-WarningMessage "The specified Source Environment: $($source) and Destination Environment: $($dest) target the same Azure Blobs. No copy steps will be performed."
            return
        }

        # If the same environments were entered for source and dest, there is no work to do.
        if($source -eq $dest) {

            Show-WarningMessage "The specified Source Environment: $($source) and Destination Environment: $($dest) are the same. No copy steps will be performed."
            return       
        }

        # If the destination environment is production, confirm the choice.
        if($dest -eq $_PROD) {

            Show-WarningMessage "The specified Destination Environment is PROD. To continue, press Y, to quit, press any other key."

            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
            # 89 is the Y key
            if($x.VirtualKeyCode -ne 89) { 
            
                Show-InfoMessage "No files will be copied."
                return
            }        
        }    

        $accessKey = ""

        if(![string]::IsNullOrEmpty($env:MOHAWKCDNKEY)) {
            
            $accessKey = $env:MOHAWKCDNKEY
        } 
        else {
            
            Show-ErrorMessage "The MOHAWKCDNKEY Environment Variable has not been set."
            return
        }        

        $blobRoot = "https://mohawkcdn.blob.core.windows.net/"

        $hqProductBlob = "$($blobRoot)pdf-product-dev/"
        $hqSustainabilityBlob = "$($blobRoot)pdf-sustainability-dev/"
        $hqTemplateBlob = "$($blobRoot)pdf-template-dev/"

        $devProductBlob = "$($blobRoot)pdf-product-dev/"
        $devSustainabilityBlob = "$($blobRoot)pdf-sustainability-dev/"
        $devTemplateBlob = "$($blobRoot)pdf-template-dev/"

        $qaProductBlob = "$($blobRoot)pdf-product-qa/"
        $qaSustainabilityBlob = "$($blobRoot)pdf-sustainability-qa/"
        $qaTemplateBlob = "$($blobRoot)pdf-template-qa/"    

        $uatProductBlob = "$($blobRoot)pdf-product-uat/"
        $uatSustainabilityBlob = "$($blobRoot)pdf-sustainability-uat/"
        $uatTemplateBlob = "$($blobRoot)pdf-template-uat/"    

        $prodProductBlob = "$($blobRoot)pdf-product-prod/"
        $prodSustainabilityBlob = "$($blobRoot)pdf-sustainability-prod/"
        $prodTemplateBlob = "$($blobRoot)pdf-template-prod/"

        $sourceProductBlob = ""
        $sourceSustainabilityBlob = ""
        $sourceTemplateBlob = ""

        $destProductBlob = ""
        $destSustainabilityBlob = ""
        $destTemplateBlob = ""

        switch($source) {

            $_HQ {
            
                $sourceProductBlob = $hqProductBlob
                $sourceSustainabilityBlob = $hqSustainabilityBlob
                $sourceTemplateBlob = $hqTemplateBlob
            
                break
            }        
            $_DEV {
            
                $sourceProductBlob = $devProductBlob
                $sourceSustainabilityBlob = $devSustainabilityBlob
                $sourceTemplateBlob = $devTemplateBlob

                break
            }
            $_QA {
            
                $sourceProductBlob = $qaProductBlob
                $sourceSustainabilityBlob = $qaSustainabilityBlob
                $sourceTemplateBlob = $qaTemplateBlob

                break
            }
            $_UAT {
            
                $sourceProductBlob = $uatProductBlob
                $sourceSustainabilityBlob = $uatSustainabilityBlob
                $sourceTemplateBlob = $uatTemplateBlob

                break
            }
            $_PROD {
            
                $sourceProductBlob = $prodProductBlob
                $sourceSustainabilityBlob = $prodSustainabilityBlob
                $sourceTemplateBlob = $prodTemplateBlob

                break
            }
            default {
            
                Show-ErrorMessage "Invalid Source Environment Specified!"
                Show-Usage
                return
            }        
        }

        switch($dest) {

            $_HQ {
            
                $destProductBlob = $hqProductBlob
                $destSustainabilityBlob = $hqSustainabilityBlob
                $destTemplateBlob = $hqTemplateBlob
            
                break
            }        
            $_DEV {
            
                $destProductBlob = $devProductBlob
                $destSustainabilityBlob = $devSustainabilityBlob
                $destTemplateBlob = $devTemplateBlob

                break
            }
            $_QA {
            
                $destProductBlob = $qaProductBlob
                $destSustainabilityBlob = $qaSustainabilityBlob
                $destTemplateBlob = $qaTemplateBlob

                break
            }
            $_UAT {
            
                $destProductBlob = $uatProductBlob
                $destSustainabilityBlob = $uatSustainabilityBlob
                $destTemplateBlob = $uatTemplateBlob

                break
            }
            $_PROD {
            
                $destProductBlob = $prodProductBlob
                $destSustainabilityBlob = $prodSustainabilityBlob
                $destTemplateBlob = $prodTemplateBlob

                break
            }
            default {

                Show-ErrorMessage "Invalid Destination Environment Specified!"
                Show-Usage
                return
            }        
        }

        Show-InfoMessage "Starting file copying..."

        Show-InfoMessage "Copying files from $($sourceProductBlob) to $($destProductBlob)"
        Invoke-Expression ("AzCopy /Source:$($sourceProductBlob) /Dest:$($destProductBlob) /SourceKey:$($accessKey) /DestKey:$($accessKey) /S /Y")

        Show-InfoMessage "Copying files from $($sourceSustainabilityBlob) to $($destSustainabilityBlob)"
        Invoke-Expression ("AzCopy /Source:$($sourceSustainabilityBlob) /Dest:$($destSustainabilityBlob) /SourceKey:$($accessKey) /DestKey:$($accessKey) /S /Y")

        Show-InfoMessage "Copying files from $($sourceTemplateBlob) to $($destTemplateBlob)"
        Invoke-Expression ("AzCopy /Source:$($sourceTemplateBlob) /Dest:$($destTemplateBlob) /SourceKey:$($accessKey) /DestKey:$($accessKey) /S /Y")

        Show-InfoMessage "File copying complete."
    }
}