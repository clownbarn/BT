Function Invoke-ElasticImport {
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
        
            Show-InfoMessage "Usage: Invoke-ElasticImport -source [source] -dest [dest]"
            Show-InfoMessage "Valid values for -source and -dest: LOCAL, DEV, QA, STAG, and PROD"
        }
        function DeleteIndex($elasticUri, $indexName) {

            try {

                Show-InfoMessage "DELETING INDEX $($elasticUri)$($indexName)"

                Invoke-WebRequest -Method DELETE -Uri "$($elasticUri)$($indexName)";
            }
            catch {
                Show-ErrorMessage "Error deleting $($indexName)";
                Show-Exception $_.Exception
            }
        }

        function CheckEnvVars() {
            
            if([string]::IsNullOrEmpty($env:MOHAWKDEVELASTICINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKDEVELASTICINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKQAELASTICINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKQAELASTICINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKSTAGELASTICINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKSTAGELASTICINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKPRODELASTICINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKPRODELASTICINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKDEVSQLINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKDEVSQLINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKQASQLINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKQASQLINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKSTAGSQLINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKSTAGSQLINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKPRODSQLINSTANCE)) {
                    
                Show-ErrorMessage "The MOHAWKSTAGSQLINSTANCE Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKAZURESQLUSER)) {
                    
                Show-ErrorMessage "The MOHAWKAZURESQLUSER Environment Variable has not been set."
                return $false
            }

            if([string]::IsNullOrEmpty($env:MOHAWKAZURESQLPASSWORD)) {
                    
                Show-ErrorMessage "The MOHAWKAZURESQLPASSWORD Environment Variable has not been set."
                return $false
            }

            return $true;
        }
    }
    Process {

        $_LOCAL = "LOCAL"
        $_DEV = "DEV"
        $_QA = "QA"
        $_STAG = "STAG"
        $_PROD = "PROD"

        # If the same environments were entered for source and dest, there is no work to do.
        if($source -eq $dest) {

            Show-WarningMessage "The specified Source Environment: $($source) and Destination Environment: $($dest) are the same. No import will be performed."
            return
        }

        # If the destination environment is production, confirm the choice.
        if($dest -eq $_PROD) {

            Show-WarningMessage "The specified Destination Environment is PROD. To continue, press Y, to quit, press any other key."

            $keyInfo = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
            # 89 is the Y key
            if($keyInfo.VirtualKeyCode -ne 89) { 
            
                Show-InfoMessage "No import will be performed."
                return
            }        
        }

        #check that all the necessary environment variables have been set.
        $checkEnvVarsResult = CheckEnvVars

        if(!$checkEnvVarsResult) {
            return
        }

        switch($source) {

            $_LOCAL {
            
                $sourceElasticInstance = "http://localhost:9200/"
                $sourceSQLServerInstance = "localhost"
                $sourceSQLUser = "sqluser"
                $sourceSQLPassword = "sqluser"
                break
            }
            $_DEV {
            
                $sourceElasticInstance = $env:MOHAWKDEVELASTICINSTANCE
                $sourceSQLServerInstance = $env:MOHAWKDEVSQLINSTANCE
                $sourceSQLUser = $env:MOHAWKAZURESQLUSER
                $sourceSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            $_QA {
            
                $sourceElasticInstance = $env:MOHAWKQAELASTICINSTANCE
                $sourceSQLServerInstance = $env:MOHAWKQASQLINSTANCE
                $sourceSQLUser = $env:MOHAWKAZURESQLUSER
                $sourceSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            $_STAG {
            
                $sourceElasticInstance = $env:MOHAWKSTAGELASTICINSTANCE
                $sourceSQLServerInstance = $env:MOHAWKSTAGSQLINSTANCE
                $sourceSQLUser = $env:MOHAWKAZURESQLUSER
                $sourceSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            $_PROD {
            
                $sourceElasticInstance = $env:MOHAWKPRODELASTICINSTANCE
                $sourceSQLServerInstance = $env:MOHAWKPRODSQLINSTANCE
                $sourceSQLUser = $env:MOHAWKAZURESQLUSER
                $sourceSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            default {
            
                Show-ErrorMessage "Invalid Source Environment Specified!"
                Show-Usage
                return
            }
        }

        $sourceActiveIndex = Invoke-Sqlcmd "SELECT TOP 1 [ColorsIndexName],[StylesIndexName],[DealersIndexName],[DurkanCollectionIndexName] FROM ElasticIndex where IsActive = 1" -ServerInstance $sourceSQLServerInstance -Database "Mohawk_Services" -Username $sourceSQLUser -Password $sourceSQLPassword

        switch($dest) {

            $_LOCAL {
            
                $destElasticInstance = "http://localhost:9200/"
                $destSQLServerInstance = "localhost"
                $destSQLUser = "sqluser"
                $destSQLPassword = "sqluser"
                break
            }
            $_DEV {
            
                $destElasticInstance = $env:MOHAWKDEVELASTICINSTANCE
                $destSQLServerInstance = $env:MOHAWKDEVSQLINSTANCE
                $destSQLUser = $env:MOHAWKAZURESQLUSER
                $destSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            $_QA {
            
                $destElasticInstance = $env:MOHAWKQAELASTICINSTANCE
                $destSQLServerInstance = $env:MOHAWKQASQLINSTANCE
                $destSQLUser = $env:MOHAWKAZURESQLUSER
                $destSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            $_STAG {
            
                $destElasticInstance = $env:MOHAWKSTAGELASTICINSTANCE
                $destSQLServerInstance = $env:MOHAWKSTAGSQLINSTANCE
                $destSQLUser = $env:MOHAWKAZURESQLUSER
                $destSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            $_PROD {
            
                $destElasticInstance = $env:MOHAWKPRODELASTICINSTANCE
                $destSQLServerInstance = $env:MOHAWKPRODSQLINSTANCE
                $destSQLUser = $env:MOHAWKAZURESQLUSER
                $destSQLPassword = $env:MOHAWKAZURESQLPASSWORD
                break
            }
            default {

                Show-ErrorMessage "Invalid Destination Environment Specified!"
                Show-Usage
                return
            }
        }
        
        $destActiveIndex = Invoke-Sqlcmd "SELECT TOP 1 [ColorsIndexName],[StylesIndexName],[DealersIndexName],[DurkanCollectionIndexName] FROM ElasticIndex where IsActive = 1" -ServerInstance $destSQLServerInstance -Database "Mohawk_Services" -Username $destSQLUser -Password $destSQLPassword

        $destStylesIndex = $destActiveIndex.StylesIndexName;
        $destColorsIndex = $destActiveIndex.ColorsIndexName;
        $destDealersIndex = $destActiveIndex.DealersIndexName;
        $destCollectionsIndex = $destActiveIndex.DurkanCollectionIndexName;

        $destIndexes = @(
            $destStylesIndex,
            $destColorsIndex,
            $destDealersIndex,
            $destCollectionsIndex
        );
        
        #TODO: Test URIs for source and dest before proceeding. If not connected to the VPN, then the below will fail.

        Show-InfoMessage "Deleting destination indexes..."

        foreach($index in $destIndexes) {
            DeleteIndex -elasticUri $destElasticInstance -indexName $index;
        }

        Show-InfoMessage "Finished deleting destintation indexes."

        $stopwatch =  [system.diagnostics.stopwatch]::StartNew()

        Show-InfoMessage "Starting import process..."

        #Styles
        Show-InfoMessage "Importing Styles."
        Show-InfoMessage "Importing Index from $($sourceElasticInstance)$($sourceActiveIndex.StylesIndexName) to $($destElasticInstance)$($destActiveIndex.StylesIndexName)"
        Invoke-Expression("elasticdump --input $($sourceElasticInstance)$($sourceActiveIndex.StylesIndexName) --output $($destElasticInstance)$($destActiveIndex.StylesIndexName)")

        #Colors
        Show-InfoMessage "Importing Colors."
        Show-InfoMessage "Importing Index from $($sourceElasticInstance)$($sourceActiveIndex.ColorsIndexName) to $($destElasticInstance)$($destActiveIndex.ColorsIndexName)"
        Invoke-Expression("elasticdump --input $($sourceElasticInstance)$($sourceActiveIndex.ColorsIndexName) --output $($destElasticInstance)$($destActiveIndex.ColorsIndexName)")

        #Dealers
        Show-InfoMessage "Importing Dealers."
        Show-InfoMessage "Importing Index from $($sourceElasticInstance)$($sourceActiveIndex.DealersIndexName) to $($destElasticInstance)$($destActiveIndex.DealersIndexName)"
        Invoke-Expression("elasticdump --input $($sourceElasticInstance)$($sourceActiveIndex.DealersIndexName) --output $($destElasticInstance)$($destActiveIndex.DealersIndexName)")

        #Durkan Collections
        Show-InfoMessage "Importing Durkan Collections."
        Show-InfoMessage "Importing Index from $($sourceElasticInstance)$($sourceActiveIndex.DurkanCollectionIndexName) to $($destElasticInstance)$($destActiveIndex.DurkanCollectionIndexName)"
        Invoke-Expression("elasticdump --input $($sourceElasticInstance)$($sourceActiveIndex.DurkanCollectionIndexName) --output $($destElasticInstance)$($destActiveIndex.DurkanCollectionIndexName)")

        Show-InfoMessage "Import process complete."

        Show-InfoMessage "Time to complete: $($stopwatch.Elapsed.Seconds) Minutes, $($stopwatch.Elapsed.Seconds) Seconds."
    }
}