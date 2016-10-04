Function Invoke-DBRestore {
    
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
        
            Show-InfoMessage "Usage: Invoke-DBRestore -database [db]"        
            Show-InfoMessage "db: services for Mohawk_Services_Dev Database"
            Show-InfoMessage "db: commercial for Mohawk_TMGCommercial Database"
            Show-InfoMessage "db: flooring for MFProduct Database"
            Show-InfoMessage "db: inventory for Mohawk_InventoryData Database"
            Show-InfoMessage "db: mongo for Mohawk_Mongo_Data Database"
            Show-InfoMessage "db: karastan for Mohawk_Karastan Database"
            Show-InfoMessage "db: dealer for Mohawk_MFDealer Database"
        }
    }
    Process {
        
        $workingDir = (Get-Item -Path ".\" -Verbose).FullName
        $databaseToRestore = "";
        $dbBackupStorageRoot = if(![string]::IsNullOrEmpty($env:DBBACKUPSTORAGEROOT)) { $env:DBBACKUPSTORAGEROOT } else { "C:\stuff\DBBackups\" }
        $dbBackupStorageDir = "";
        $backupFileName = "";

        switch($database)
        {
            "services"
                {                     
                    $databaseToRestore = "Mohawk_Services_Dev"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Services"
                    break                    
                }
            "commercial"
                {                     
                    $databaseToRestore = "Mohawk_TMGCommercial"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)TMGCommercial"
                    break                    
                }
            "flooring"
                {                     
                    $databaseToRestore = "Mohawk_MFProduct"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MFProduct"
                    break                    
                }
            "inventory"
                {                     
                    $databaseToRestore = "Mohawk_InventoryData"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_InventoryData"
                    break                    
                }
            "mongo"
                {                     
                    $databaseToRestore = "Mohawk_Mongo_Data"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Mongo_Data"
                    break                    
                }
            "karastan"
                {                     
                    $databaseToRestore = "Mohawk_Karastan"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Karastan"
                    break                    
                }
            "dealer"
                {                     
                    $databaseToRestore = "Mohawk_MFDealer"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_MFDealer"
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
        
        if(![string]::IsNullOrEmpty($backupFileName)) {

            $backupFilePath = "$($dbBackupStorageDir)\$($backupFileName)"

            Show-WarningMessage "Preparing to restore from file: $($backupFilePath). The $($databaseToRestore) database will be overwritten. To continue press Y. To quit, press any other key."

            $keyInfo = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
            # 89 is the Y key
            if($keyInfo.VirtualKeyCode -ne 89) { 
            
                Show-InfoMessage "The restore operation was cancelled."
                return
            }
        
            Show-InfoMessage "Restoring $($databaseToRestore) Database from file: $($backupFileName)..."

            # Second, restart SQL Server to drop any open connections.
            $sqlServiceCommand = "net stop MSSQLSERVER"
            Invoke-Expression -Command:$sqlServiceCommand
        
            $sqlServiceCommand = "net start MSSQLSERVER"
            Invoke-Expression -Command:$sqlServiceCommand
        
            Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"

            $sqlServer = New-Object "Microsoft.SqlServer.Management.SMO.Server"
                    
            if($sqlServer.databases[$databaseToRestore])
            {
                $sqlServer.databases[$databaseToRestore].Drop()
            }

            # Third, Restore the database.
            $sqlServerName = $sqlServer.Name

            $smoExtendedAssemblyInfo = "Microsoft.SqlServer.SmoExtended, Version=12.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91"

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