Function Invoke-BacPacRestore {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$database
    )            
    Begin {
        
        <#
            Helper function to show usage of cmdlet.
        #>
        Function Show-Usage {
        
            Show-InfoMessage "Usage: Invoke-BacPacRestore -database [db]"
            Show-InfoMessage "[database]: services for Mohawk_Services_Dev Database"
            Show-InfoMessage "[database]: commercial for Mohawk_TMGCommercial Database"
            Show-InfoMessage "[database]: residential for MFProduct Database"
            Show-InfoMessage "[database]: inventory for Mohawk_InventoryData Database"
            Show-InfoMessage "[database]: mongo for Mohawk_Mongo_Data Database"
            Show-InfoMessage "[database]: karastan for Mohawk_Karastan Database"
            Show-InfoMessage "[database]: home for MohawkHome Database"
            Show-InfoMessage "[database]: dealer for Mohawk_MFDealer Database"
            Show-InfoMessage "[database]: durkan for Mohawk_Durkan Database"
            Show-InfoMessage "[database]: sitecorea for Mohawk_Sitecore_Analytics"
            Show-InfoMessage "[database]: sitecorec for Mohawk_Sitecore_Core"
            Show-InfoMessage "[database]: sitecorem for Mohawk_Sitecore_Master"
            Show-InfoMessage "[database]: sitecorew for Mohawk_Sitecore_Web"
            Show-InfoMessage "[database]: bmfsca for MohawkBmf_reporting"
            Show-InfoMessage "[database]: bmfscc for MohawkBmf_core"
            Show-InfoMessage "[database]: bmfscm for MohawkBmf_master"
            Show-InfoMessage "[database]: bmfscw for MohawkBmf_web"
            Show-InfoMessage "[database]: aladdinsca for AladdinCommercial_Sitecore_reporting"
            Show-InfoMessage "[database]: aladdinscc for AladdinCommercial_Sitecore_core"
            Show-InfoMessage "[database]: aladdinscm for AladdinCommercial_Sitecore_master"
            Show-InfoMessage "[database]: aladdinscw for AladdinCommercial_Sitecore_web"
        }
    }
    Process {
        
        $workingDir = (Get-Item -Path ".\" -Verbose).FullName
        $databaseToRestore = "";
        $dbBackupStorageRoot = if(![string]::IsNullOrEmpty($env:DBBACKUPSTORAGEROOT)) { $env:DBBACKUPSTORAGEROOT } else { "C:\stuff\DBBackups\" }
        $dbBackupStorageDir = "";
        $backupFileName = "";
        
        $_SERVICES_DB = "services"
        $_COMMERCIAL_DB = "commercial"
        $_RESIDENTIAL_DB = "residential"
        $_INVENTORY_DB = "inventory"
        $_MONGO_DB = "mongo"
        $_KARASTAN_DB = "karastan"
        $_HOME_DB = "home"
        $_DEALER_DB = "dealer"
        $_DURKAN_DB = "durkan"
        $_SITECORE_ANALYTICS_DB = "sitecorea"
        $_SITECORE_CORE_DB = "sitecorec"
        $_SITECORE_MASTER_DB = "sitecorem"
        $_SITECORE_WEB_DB = "sitecorew"
        $_BMF_SITECORE_ANALYTICS_DB = "bmfsca"
        $_BMF_SITECORE_CORE_DB = "bmfscc"
        $_BMF_SITECORE_MASTER_DB = "bmfscm"
        $_BMF_SITECORE_WEB_DB = "bmfscw"
        $_ALADDIN_SITECORE_ANALYTICS_DB = "aladdinsca"
        $_ALADDIN_SITECORE_CORE_DB = "aladdinscc"
        $_ALADDIN_SITECORE_MASTER_DB = "aladdinscm"
        $_ALADDIN_SITECORE_WEB_DB = "aladdinscw"

        switch($database)
        {
            $_SERVICES_DB
                {
                    $databaseToRestore = "Mohawk_Services_Dev"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Services"
                    break
                }
            $_COMMERCIAL_DB
                {
                    $databaseToRestore = "Mohawk_TMGCommercial"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)TMGCommercial"
                    break
                }
            $_RESIDENTIAL_DB
                {
                    $databaseToRestore = "Mohawk_MFProduct"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MFProduct"
                    break
                }
            $_INVENTORY_DB
                {
                    $databaseToRestore = "Mohawk_InventoryData"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_InventoryData"
                    break
                }
            $_MONGO_DB
                {
                    $databaseToRestore = "Mohawk_Mongo_Data"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Mongo_Data"
                    break
                }
            $_KARASTAN_DB
                {
                    $databaseToRestore = "Mohawk_Karastan"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Karastan"
                    break
                }
            $_HOME_DB
                {
                    $databaseToRestore = "MohawkHome"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MohawkHome"
                    break
                }
            $_DEALER_DB
                {
                    $databaseToRestore = "Mohawk_MFDealer"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_MFDealer"
                    break
                }
            $_DURKAN_DB
                {
                    $databaseToRestore = "Mohawk_Durkan"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Durkan"
                    break
                }
            $_SITECORE_ANALYTICS_DB
                {
                    $databaseToRestore = "Mohawk_Sitecore_Analytics"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Analytics"
                    break
                }
            $_SITECORE_CORE_DB
                {
                    $databaseToRestore = "Mohawk_Sitecore_Core"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Core"
                    break
                }
            $_SITECORE_MASTER_DB
                {
                    $databaseToRestore = "Mohawk_Sitecore_Master"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Master"
                    break
                }
            $_SITECORE_WEB_DB
                {
                    $databaseToRestore = "Mohawk_Sitecore_Web"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Web"
                    break
                }
            $_BMF_SITECORE_ANALYTICS_DB
                {
                    $databaseToRestore = "MohawkBmf_reporting"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MohawkBmf_reporting"
                    break
                }
            $_BMF_SITECORE_CORE_DB
                {
                    $databaseToRestore = "MohawkBmf_core"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MohawkBmf_core"
                    break
                }
            $_BMF_SITECORE_MASTER_DB
                {
                    $databaseToRestore = "MohawkBmf_master"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MohawkBmf_master"
                    break
                }
            $_BMF_SITECORE_WEB_DB
                {
                    $databaseToRestore = "MohawkBmf_web"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MohawkBmf_web"
                    break
                }                
            $_ALADDIN_SITECORE_ANALYTICS_DB
                {
                    $databaseToRestore = "AladdinCommercial_Sitecore_reporting"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)AladdinCommercial_Sitecore_reporting"
                    break
                }
            $_ALADDIN_SITECORE_CORE_DB
                {
                    $databaseToRestore = "AladdinCommercial_Sitecore_core"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)AladdinCommercial_Sitecore_core"
                    break
                }
            $_ALADDIN_SITECORE_MASTER_DB
                {
                    $databaseToRestore = "AladdinCommercial_Sitecore_master"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)AladdinCommercial_Sitecore_master"
                    break
                }
            $_ALADDIN_SITECORE_WEB_DB
                {
                    $databaseToRestore = "AladdinCommercial_Sitecore_web"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)AladdinCommercial_Sitecore_web"
                    break
                }

            default {
                Show-InfoMessage "Invalid Database"
                Show-Usage
                return
            }
        }

        # First get the backup file name. This will be from the last backup done.
        $backupFiles = Get-ChildItem -path $dbBackupStorageDir -File
        $backupFileName = $backupFiles | Sort-Object LastWriteTime | Select-Object -last 1
        
        if([string]::IsNullOrEmpty($backupFileName)) {

            Show-ErrorMessage "Restore failed. No bacpac file found!"
        }
        else {
        
            $backupFilePath = "$($dbBackupStorageDir)\$($backupFileName)"

            Show-WarningMessage "Preparing to restore from file: $($backupFilePath). The $($databaseToRestore) database will be overwritten. To continue press Y. To quit, press any other key."

            $keyInfo = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
            # 89 is the Y key
            if($keyInfo.VirtualKeyCode -ne 89) { 
            
                Show-InfoMessage "The restore operation was cancelled."
                return
            }
            
            # Second, initialize SQL SMO            
            if(Test-Path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll") {
      
                #Show-InfoMessage "Adding Type: C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
            }
            else {
            
                #Show-InfoMessage "Adding Type: C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
            }

            $sqlServer = New-Object "Microsoft.SqlServer.Management.SMO.Server"
            
            # Third, restart SQL Server to drop any open connections.
            $sqlServiceCommand = "net stop MSSQLSERVER"
            Invoke-Expression -Command:$sqlServiceCommand
        
            $sqlServiceCommand = "net start MSSQLSERVER"
            Invoke-Expression -Command:$sqlServiceCommand
                    
            if($sqlServer.databases[$databaseToRestore])
            {
                $sqlServer.databases[$databaseToRestore].Drop()
            }

            # Fourth, initialize SQL DAC Services.
            if(Test-Path "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin\Microsoft.SqlServer.Dac.dll") {
                
                #Show-InfoMessage "Adding Type: C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin\Microsoft.SqlServer.Dac.dll"
                Add-Type -path "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin\Microsoft.SqlServer.Dac.dll"
            }
            else {
            
                #Show-InfoMessage "Adding Type: C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\Microsoft.SqlServer.Dac.dll"
                Add-Type -path "C:\Program Files (x86)\Microsoft SQL Server\120\DAC\bin\Microsoft.SqlServer.Dac.dll"
            }
            
            $conn = "Data Source=localhost;Initial Catalog=master;Connection Timeout=0;Integrated Security=True;"
            $dacServices = New-Object Microsoft.SqlServer.Dac.DacServices $conn
            $package = [Microsoft.SqlServer.Dac.BacPackage]::Load($backupFilePath)
            
            # Fifth, Restore the database.
            Show-InfoMessage "Restoring $($databaseToRestore) Database from file: $($backupFileName)..."

            $dacServices.ImportBacpac($package, $databaseToRestore)
            $package.Dispose()

            Show-InfoMessage ($databaseToRestore + " Database Restore Complete.")
        }

        Set-Location $workingDir
    }
}