Function Invoke-DBRestore {
    
    # TODO: Get the sitecore backups into one step.

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
        
            Show-InfoMessage "Usage: Invoke-DBRestore -database [db]"        
            Show-InfoMessage "[database]: services for Mohawk_Services_Dev Database"
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
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Services_Dev"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Services_Dev"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Services_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_Services_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_Services"
                    }                                        
                    
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Services"
                    break                    
                }
            $_COMMERCIAL_DB
                {   
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_TMGCommercial"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "TMGCommercial_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "TMGCommercial_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "TMGCommercial_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "TMGCommercial"
                    }
                                        
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)TMGCommercial"
                    break                    
                }
            $_RESIDENTIAL_DB
                {                     
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_MFProduct"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "MFProduct_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "MFProduct_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "MFProductStaging"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "MFProduct"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MFProduct"
                    break                    
                }
            $_INVENTORY_DB
                {                     
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_InventoryData"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_InventoryData_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_InventoryData_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_InventoryData_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_InventoryData"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_InventoryData"
                    break                    
                }
            $_MONGO_DB
                {                     
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Mongo_Data"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Mongo_Data_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Mongo_Data_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_Mongo_Data_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_Mongo_Data"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Mongo_Data"
                    break                    
                }
            $_KARASTAN_DB
                {                     
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Karastan"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Karastan_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Karastan_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "MFKarastanStaging"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "MFKarastan"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Karastan"
                    break                    
                }
            $_DEALER_DB
                {                     
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_MFDealer"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "MFDealer_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "MFDealer_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "MFDealerStaging"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "MFDealer"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_MFDealer"
                    break                    
                }
            $_DURKAN_DB
                {                     
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Durkan"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Durkan_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Durkan_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_Durkan_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_Durkan"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Durkan"
                    break                    
                }
            $_SITECORE_ANALYTICS_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Sitecore_Analytics"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Sitecore_Analytics_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Sitecore_Analytics_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_Sitecore_Analytics_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_Durkan"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Analytics"
					break
                }
            $_SITECORE_CORE_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Sitecore_Core"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Sitecore_Core_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Sitecore_Core_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_Sitecore_Core_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_Sitecore_Core"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Core"
					break
                }
            $_SITECORE_MASTER_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Sitecore_Master"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Sitecore_Master_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Sitecore_Master_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_Sitecore_Master_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_Sitecore_Master"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Master"
					break
                }
            $_SITECORE_WEB_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToRestore = "Mohawk_Sitecore_Web"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToRestore = "Mohawk_Sitecore_Web_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_Sitecore_Web_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToRestore = "Mohawk_Sitecore_Web_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToRestore = "Mohawk_Sitecore_Web"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Web"
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
        $backupFileName = $backupFiles | sort LastWriteTime | select -last 1
        
        if([string]::IsNullOrEmpty($backupFileName)) {

            Show-ErrorMessage "Restore failed. No backup file found!"
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
        
            Show-InfoMessage "Restoring $($databaseToRestore) Database from file: $($backupFileName)..."            
            
            # Second, initialize SQL SMO
            $smoExtendedAssemblyInfo = ""			
			
            if(Test-Path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll") {
      
                #Show-InfoMessage "Adding Type: C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                $smoExtendedAssemblyInfo = "Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
            }
            else {
            
                #Show-InfoMessage "Adding Type: C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                $smoExtendedAssemblyInfo = "Microsoft.SqlServer.SmoExtended, Version=13.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
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

            # Fourth, Restore the database.
            $sqlServerName = $sqlServer.Name            

            $restore = New-Object "Microsoft.SqlServer.Management.Smo.Restore, $($smoExtendedAssemblyInfo)"
            $backupDevice = New-Object "Microsoft.SqlServer.Management.Smo.BackupDeviceItem, $($smoExtendedAssemblyInfo)" ($backupFilePath, "File")
            $restore.Devices.Add($backupDevice)
            $fileList = $restore.ReadFileList($sqlServer)
            $logicalDataFileName = $fileList.Select("Type = 'D'")[0].LogicalName
            $logicalLogFileName = $fileList.Select("Type = 'L'")[0].LogicalName

            $relocateData = New-Object "Microsoft.SqlServer.Management.Smo.RelocateFile, $($smoExtendedAssemblyInfo)" ($logicalDataFileName, "$($sqlServer.MasterDBPath)\$($databaseToRestore).mdf")
            $relocateLog = New-Object "Microsoft.SqlServer.Management.Smo.RelocateFile, $($smoExtendedAssemblyInfo)" ($logicalLogFileName, "$($sqlServer.MasterDBLogPath)\$($databaseToRestore).ldf")            

            Restore-SqlDatabase -ServerInstance $sqlServerName -Database $databaseToRestore -BackupFile $backupFilePath -RelocateFile @($relocateData,$relocateLog)

            Show-InfoMessage ($databaseToRestore + " Database Restore Complete.")            
        }

        cd $workingDir        
    }
}