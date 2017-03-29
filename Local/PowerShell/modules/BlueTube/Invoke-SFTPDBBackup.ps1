# Invoke-SFTPDBBackup is a Powershell Cmdlet that backs up a specified
# Mohawk database for a specified environment and uploads the backup file to the SFTP server.
# 
# Internally, the backup is performed using the Invoke-DBBackup CmdLet.
#
# This CmdLet has a dependency on WinSCP: https://winscp.net/eng/index.php
#
# Example Usage: Invoke-SFTPDBBackup -database services -env LOCAL
#
# Valid Values for -database: services, commercial, residential, inventory, mongo, karastan, dealer, durkan, sitecorea, sitecorec, sitecorem, sitecorew
# Valid values for -env: LOCAL, DEV, QA, UAT, and PROD
#
# Environment variables required: 
#    BTFTP must be set to the address of the sftp server, ie. sftp://lfsftp.perficient.com/
#    BTFTPUSER must be set to the user name for the sftp server.
#    BTFTPPWD must be set to the user password for the sftp server.
#    BTSSHHOSTKEYFINGERPRINT must be set to the value of the SSH Host Key Fingerprint for the SFTP server.
  
Function Invoke-SFTPDBBackup
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
        
            Show-InfoMessage "Usage: Invoke-SFTPDBBackup -database [database] -env [env]"        
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

                cd $dbBackupStorageDir            

                # ftp server address and credentials
                $ftp = $env:BTFTP 
                $user = $env:BTFTPUSER
                $pwd = $env:BTFTPPWD
                $sshFingerprint = $env:BTSSHHOSTKEYFINGERPRINT

                if([string]::IsNullOrEmpty($ftp)) {
                    throw "The BTFTP environment variable has not been set to the SFTP server address."
                }

                if([string]::IsNullOrEmpty($user)) {
                    throw "The BTFTPUSER environment variable has not been set to the SFTP user name."
                }

                if([string]::IsNullOrEmpty($pwd)) {
                    throw "The BTFTPPWD environment variable has not been set to the SFTP user password."
                }

                if([string]::IsNullOrEmpty($sshFingerprint)) {
                    throw "The BTSSHHOSTKEYFINGERPRINT environment variable has not been set to value of the SSH Host Key Fingerprint for the SFTP server."
                }

                # Setup session options
                $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
                    Protocol = [WinSCP.Protocol]::Sftp
                    HostName = $ftp
                    UserName = $user
                    Password = $pwd
                    SshHostKeyFingerprint = $sshFingerprint
                }

                $session = New-Object WinSCP.Session
 
                try
                {
                    # Connect
                    $session.Open($sessionOptions)
                
                    # Upload files
                    $transferOptions = New-Object WinSCP.TransferOptions
                    $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
                    $transferResult = $session.PutFiles($backupFilePath, "/Mohawk/", $False, $transferOptions)
 
                    # Throw on any error
                    $transferResult.Check()
 
                    Show-InfoMessage "Upload of database backup file: $($backupFileName) complete." 
                
                    # Cleanup local backup file.
                    Invoke-Expression ("del $('$backupFilePath')")
                        
                }
                finally
                {
                    # Disconnect, clean up
                    $session.Dispose()
                }   
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