# Invoke-AZDBBackup is a Powershell Cmdlet that backs up a specified
# Mohawk database for a specified environment and uploads the backup file to Mohawk Azure Storage Account.
# 
# Internally, the backup is performed using the Invoke-DBBackup CmdLet.
#
# This script has a dependency on the AzCopy Executable, which must be in the PATH
# Environment Variable where this script is used.
#
# AzCopy can be obtained here: http://aka.ms/downloadazcopy
# 
# Once installed, ensure the executable is in the PATH Environment Variable. The default installation
# path for AzCopy is typically : %PROGRAMFILES(X86)%\Microsoft SDKs\Azure\AzCopy
#
# Example Usage: Invoke-AZDBBackup -database services -env LOCAL
#
# Valid Values for -database: services, commercial, residential, inventory, mongo, karastan, dealer, durkan, sitecorea, sitecorec, sitecorem, sitecorew
# Valid values for -env: LOCAL, DEV, QA, UAT, and PROD
#
# Environment variable required: 
#    MOHAWKKEY must be set to the value of the key for the Mohawk Storage Account
  
Function Invoke-AZDBBackup
{
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$database,  
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$env   
        )
    Begin {
        
        <#
            Helper function to show usage of cmdlet.
        #>
        Function Show-Usage {
        
            Show-InfoMessage "Usage: Invoke-AZDBBackup -database [database] -env [env]"        
            Show-InfoMessage "[database]: services for Mohawk_Services Database"
            Show-InfoMessage "[database]: commercial for Mohawk_TMGCommercial Database"
            Show-InfoMessage "[database]: residential for MFProduct Database"
            Show-InfoMessage "[database]: inventory for Mohawk_InventoryData Database"
            Show-InfoMessage "[database]: mongo for Mohawk_Mongo_Data Database"
            Show-InfoMessage "[database]: karastan for Mohawk_Karastan Database"
            Show-InfoMessage "[database]: dealer for Mohawk_MFDealer Database"
            Show-InfoMessage "[database]: durkan for Mohawk_Durkan Database"
            Show-InfoMessage "[database]: sitecorea for Mohawk_Sitecore_Analytics"
            Show-InfoMessage "[database]: sitecorec for Mohawk_Sitecore_Core"
            Show-InfoMessage "[database]: sitecorem for Mohawk_Sitecore_Master"
            Show-InfoMessage "[database]: sitecorew for Mohawk_Sitecore_Web"
            Show-InfoMessage "Valid values for [env]: LOCAL, DEV, QA, UAT, and PROD"
        }
    }    
    Process {
        
        try {
            
            $_LOCAL = "LOCAL"
            $_DEV = "DEV"
            $_QA = "QA"
            $_UAT = "UAT"
            $_PROD = "PROD"

            # Validate $env parameter
            if(!(($env -eq $_LOCAL) -or ($env -eq $_DEV) -or ($env -eq $_QA) -or ($env -eq $_UAT) -or ($env -eq $_PROD))) {

                Show-InfoMessage "Invalid environment specified."
                Show-Usage
                return
            }
                        
            $workingDir = (Get-Item -Path ".\" -Verbose).FullName
            $dbBackupStorageRoot = if(![string]::IsNullOrEmpty($env:DBBACKUPSTORAGEROOT)) { $env:DBBACKUPSTORAGEROOT } else { "C:\stuff\DBBackups\" }
            $dbBackupStorageDir = "";

            $_SERVICES_DB = "services"
            $_COMMERCIAL_DB = "commercial"
            $_RESIDENTIAL_DB = "residential"
            $_INVENTORY_DB = "inventory"
            $_MONGO_DB = "mongo"
            $_KARASTAN_DB = "karastan"
            $_DEALER_DB = "dealer"
            $_DURKAN_DB = "durkan"
            $_SITECORE_ANALYTICS_DB = "sitecorea"
            $_SITECORE_CORE_DB = "sitecorec"
            $_SITECORE_MASTER_DB = "sitecorem"
            $_SITECORE_WEB_DB = "sitecorew"

            switch($database)
            {
                $_SERVICES_DB
                    {
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Services"
                        break                    
                    }
                $_COMMERCIAL_DB
                    { 
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)TMGCommercial"
                        break                    
                    }
                $_RESIDENTIAL_DB
                    {  
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)MFProduct"
                        break                    
                    }
                $_INVENTORY_DB
                    {
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_InventoryData"
                        break                    
                    }
                $_MONGO_DB
                    {  
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Mongo_Data"
                        break                    
                    }
                $_KARASTAN_DB
                    {  
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Karastan"
                        break                    
                    }
                $_DEALER_DB
                    {   
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_MFDealer"
                        break                    
                    }
                $_DURKAN_DB
                    {   
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Durkan"
                        break                    
                    }                
                $_SITECORE_ANALYTICS_DB
                    {   
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Analytics"
                        break                    
                    }
                $_SITECORE_CORE_DB
                    {   
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Core"
                        break                    
                    }
                $_SITECORE_MASTER_DB
                    {   
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Master"
                        break                    
                    }
                $_SITECORE_WEB_DB
                    {   
                        $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Web"
                        break                    
                    }
            

                default {
                    Show-InfoMessage "Invalid Database"
                    Show-Usage
                    return
                }
            }
            
            # First back up the SQL Server Database
            Invoke-DBBackup -database $database -env $env

            Show-InfoMessage ("Preparing to upload " + $database + " Database...")

            # First get the backup file name. This will be from the last backup done.
            $backupFiles = Get-ChildItem -path $dbBackupStorageDir -File

            $backupFileName = $backupFiles | sort LastWriteTime | select -last 1
        
            if(![string]::IsNullOrEmpty($backupFileName)) {

                $backupFilePath = "$($dbBackupStorageDir)\$($backupFileName)"

                Show-WarningMessage "Preparing to upload file: $($backupFilePath). To continue press Y. To quit, press any other key."
                                               
                $keyInfo = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
                # 89 is the Y key
                if($keyInfo.VirtualKeyCode -ne 89) { 
            
                    Show-InfoMessage "The backup operation was cancelled."
                    return
                }
                                        
                Show-InfoMessage "Uploading database backup file: $($backupFileName)..."

                $blobRoot = "https://mohawk.blob.core.windows.net/"
                $destBlob = "$($blobRoot)database-backup/"
                $accessKey = $env:MOHAWKKEY

                if([string]::IsNullOrEmpty($accessKey)) {
                    throw "The MOHAWKCDNKEY Environment Variable has not been set."
                }

                # Upload file to Mohawk Storage Account with AzCopy
                Invoke-Expression ("AzCopy /Source:$($dbBackupStorageDir) /Pattern:$($backupFileName) /Dest:$($destBlob) /DestKey:$($accessKey) /Y")
                                               
                Show-InfoMessage "Upload of database backup file: $($backupFileName) complete." 
                                
                # Cleanup local backup file.
                Invoke-Expression ("del $('$backupFilePath')")     
            } 
        }
        catch {
            
            Show-Exception $_.Exception 
        }
        finally {

            if(![string]::IsNullOrEmpty($workingDir)) {
                cd $workingDir
            }
        }
    }
}