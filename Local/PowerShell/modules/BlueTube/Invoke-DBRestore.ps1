Function Invoke-DBRestore {
    
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
            Show-InfoMessage "db: services for Mohawk_Services_Dev Database"
            Show-InfoMessage "db: commercial for Mohawk_TMGCommercial Database"
            Show-InfoMessage "db: residential for MFProduct Database"
            Show-InfoMessage "db: inventory for Mohawk_InventoryData Database"
            Show-InfoMessage "db: mongo for Mohawk_Mongo_Data Database"
            Show-InfoMessage "db: karastan for Mohawk_Karastan Database"
            Show-InfoMessage "db: dealer for Mohawk_MFDealer Database"
            Show-InfoMessage "db: durkan for Mohawk_Durkan Database"
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
					    $databaseToRestore = "Mohawk_MFDealer_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToRestore = "Mohawk_MFDealer_QA"
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
        {

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

            if(Test-Path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll") {
            
                Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                $smoExtendedAssemblyInfo = "Microsoft.SqlServer.SmoExtended, Version=13.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
            }
            else
            {
                Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
                $smoExtendedAssemblyInfo = "Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"
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