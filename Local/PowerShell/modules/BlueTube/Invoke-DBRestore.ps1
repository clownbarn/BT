﻿Function Invoke-DBRestore {
    
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
            Show-InfoMessage "db: mongo for Mohawk_Mongo_Data Database"
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
            "mongo"
                {                     
                    $databaseToRestore = "Mohawk_Mongo_Data"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Mongo_Data"
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

        
            Show-InfoMessage ("Restoring " + $databaseToRestore + " Database from file: " + $backupFileName + "...")

            # Second, restart SQL Server to drop any open connections.
            $sqlServiceCommand = "net stop MSSQLSERVER"
            Invoke-Expression -Command:$sqlServiceCommand
        
            $sqlServiceCommand = "net start MSSQLSERVER"
            Invoke-Expression -Command:$sqlServiceCommand
        
            Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\10.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"

            $sqlServer = New-Object "Microsoft.SqlServer.Management.SMO.Server"
        
            if($sqlServer.databases[$databaseToRestore])
            {
                $sqlServer.databases[$databaseToRestore].Drop()
            }

            # Third, Restore the database.
            $sqlServerName = $sqlServer.Name      

            Restore-SqlDatabase -ServerInstance $sqlServerName -Database $databaseToRestore -BackupFile $backupFilePath

            Show-InfoMessage ($databaseToRestore + " Database Restore Complete.")            
        }

        cd $workingDir        
    }
}