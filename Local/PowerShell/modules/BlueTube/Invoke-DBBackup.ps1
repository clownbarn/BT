Function Invoke-DBBackup {
    
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
        
			Show-InfoMessage "Usage: Invoke-DBBackup -database [db]"        
			Show-InfoMessage "db: services for Mohawk_Services_Dev Database"
            Show-InfoMessage "db: commercial for Mohawk_TMGCommercial Database"
			Show-InfoMessage "db: flooring for MFProduct Database"
			Show-InfoMessage "db: inventory for Mohawk_InventoryData Database"
			Show-InfoMessage "db: mongo for Mohawk_Mongo_Data Database"
		}
	}
	Process {
        
		$workingDir = (Get-Item -Path ".\" -Verbose).FullName
		$databaseToBackup = "";
        $dbBackupStorageRoot = if(![string]::IsNullOrEmpty($env:DBBACKUPSTORAGEROOT)) { $env:DBBACKUPSTORAGEROOT } else { "C:\stuff\DBBackups\" }
        $dbBackupStorageDir = "";

		switch($database)
		{
			"services"
				{                     
					$databaseToBackup = "Mohawk_Services_Dev"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Services"
					break                    
				}
            "commercial"
				{                     
					$databaseToBackup = "Mohawk_TMGCommercial"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)TMGCommercial"
					break                    
				}
			"flooring"
				{                     
					$databaseToBackup = "Mohawk_MFProduct"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MFProduct"
					break                    
				}
			"inventory"
				{                     
					$databaseToBackup = "Mohawk_InventoryData"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_InventoryData"
					break                    
				}
            "mongo"
				{                     
					$databaseToBackup = "Mohawk_Mongo_Data"
                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Mongo_Data"
					break                    
				}
            

			default {
				Show-InfoMessage "Invalid Database"
				Show-Usage
				return
			}
		}

		Show-InfoMessage ("Backing Up " + $databaseToBackup + " Database...")
		
        Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\10.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"

		$sqlServer = New-Object 'Microsoft.SqlServer.Management.SMO.Server' <#$inst#>
        
        $sqlServerName = $sqlServer.Name
		$backupdir = $sqlServer.Settings.BackupDirectory
		$currentDateTime = get-date -format yyyyMMddHHmmss
		$backupFileName = "$($databaseToBackup)_$($currentDateTime).bak"
        $backupFilePath = "$($backupdir)\$($backupFileName)"

		Backup-SqlDatabase -ServerInstance $sqlServerName -Database $databaseToBackup -BackupFile $backupFilePath

		Show-InfoMessage ($databaseToBackup + " Database Back Up Complete.")
        
        Show-InfoMessage ("Copying $($backupFilePath) to local storage directory: $($dbBackupStorageDir)")

        Invoke-Expression ("copy $('$backupFilePath') $($dbBackupStorageDir)\$($backupFileName)")

		cd $workingDir        
	}
}