# Invoke-DBBackup is a Powershell Cmdlet that backs up a specified
# Mohawk database for a specified environment.
#
# Example Usage: Invoke-DBBackup -database services -env LOCAL
#
# Valid Values for -database: services, commercial, residential, inventory, mongo, karastan, dealer, durkan
# Valid values for -env: LOCAL, DEV, QA, UAT, and PROD
#
# Environment variable required: DBBACKUPSTORAGEROOT must be set to the path where backups are to be stored.

Function Invoke-DBBackup {
    
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
        
			Show-InfoMessage "Usage: Invoke-DBBackup -database [database] -env [env]"        
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
		$databaseToBackup = "";
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
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Services_Dev"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Services_Dev"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Services_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_Services_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_Services"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Services"
					break                    
				}
            $_COMMERCIAL_DB
				{					
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_TMGCommercial"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "TMGCommercial_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "TMGCommercial_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "TMGCommercial_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "TMGCommercial"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)TMGCommercial"
					break                    
				}
			$_RESIDENTIAL_DB
				{					
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_MFProduct"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "MFProduct_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "MFProduct_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "MFProductStaging"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "MFProduct"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)MFProduct"
					break                    
				}
			$_INVENTORY_DB
				{					
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_InventoryData"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_InventoryData_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_InventoryData_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_InventoryData_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_InventoryData"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_InventoryData"
					break                    
				}
            $_MONGO_DB
				{
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Mongo_Data"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Mongo_Data_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Mongo_Data_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_Mongo_Data_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_Mongo_Data"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Mongo_Data"
					break                    
				}
            $_KARASTAN_DB
				{					
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Karastan"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Karastan_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Karastan_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "MFKarastanStaging"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "MFKarastan"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Karastan"
					break                    
				}
            $_DEALER_DB
				{
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_MFDealer"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_MFDealer_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_MFDealer_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "MFDealerStaging"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "MFDealer"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_MFDealer"
					break                    
				}
            $_DURKAN_DB
				{
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Durkan"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Durkan_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Durkan_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_Durkan_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_Durkan"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Durkan"
					break                    
				}
            $_SITECORE_ANALYTICS_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Sitecore_Analytics"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Sitecore_Analytics_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Sitecore_Analytics_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_Sitecore_Analytics_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_Sitecore_Analytics"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Analytics"
					break
                }
            $_SITECORE_CORE_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Sitecore_Core"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Sitecore_Core_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Sitecore_Core_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_Sitecore_Core_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_Sitecore_Core"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Core"
					break
                }
            $_SITECORE_MASTER_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Sitecore_Master"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Sitecore_Master_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Sitecore_Master_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_Sitecore_Master_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_Sitecore_Master"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Master"
					break
                }
            $_SITECORE_WEB_DB
                {
                    if($env -eq $_LOCAL) {
					    $databaseToBackup = "Mohawk_Sitecore_Web"
                    }
                    elseif($env -eq $_DEV) {
					    $databaseToBackup = "Mohawk_Sitecore_Web_DEV"
                    }
                    elseif($env -eq $_QA) {
                        $databaseToBackup = "Mohawk_Sitecore_Web_QA"
                    }
                    elseif($env -eq $_UAT) {
                        $databaseToBackup = "Mohawk_Sitecore_Web_STG"
                    }
                    elseif($env -eq $_PROD) {
                        $databaseToBackup = "Mohawk_Sitecore_Web"
                    }

                    $dbBackupStorageDir = "$($dbBackupStorageRoot)Mohawk_Sitecore_Web"
					break
                }
            

			default {
				Show-InfoMessage "Invalid Database specified."
				Show-Usage
				return
			}
		}

		Show-InfoMessage ("Backing Up " + $databaseToBackup + " Database...")
		        
        if(Test-Path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll") {
            
            Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\13.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"
        }
        else
        {
            Add-Type -path "C:\Windows\assembly\GAC_MSIL\Microsoft.SqlServer.Smo\12.0.0.0__89845dcd8080cc91\Microsoft.SqlServer.Smo.dll"            
        }

		$sqlServer = New-Object "Microsoft.SqlServer.Management.SMO.Server"
        
        $sqlServerName = $sqlServer.Name
		$backupdir = $sqlServer.Settings.BackupDirectory
		$currentDateTime = get-date -format yyyyMMddHHmmss
		$backupFileName = "$($databaseToBackup)_$($currentDateTime).bak"
        $backupFilePath = "$($backupdir)\$($backupFileName)"

		Backup-SqlDatabase -ServerInstance $sqlServerName -Database $databaseToBackup -BackupFile $backupFilePath

		Show-InfoMessage ($databaseToBackup + " Database Back Up Complete.")
        
        Show-InfoMessage ("Copying $($backupFilePath) to local storage directory: $($dbBackupStorageDir)")

        Invoke-Expression ("copy $('$backupFilePath') $($dbBackupStorageDir)\$($backupFileName)")

        Invoke-Expression ("del $('$backupFilePath')")

		if(![string]::IsNullOrEmpty($workingDir)) {
            cd $workingDir
        }        
	}
}