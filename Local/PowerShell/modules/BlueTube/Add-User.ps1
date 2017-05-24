Function Add-User {
    [cmdletbinding()]
    Param(        
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$userName,
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [securestring]$password,
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$fullName,
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] #No value
        [string]$groupName
    )
    Begin {
        
        <#
            Helper function to show usage of cmdlet.
        #>
        Function Show-Usage {
        
            Show-InfoMessage "Usage: Add-User -userName [userName] -password [password] -fullName [fullName] -groupName [groupName]"
        }
    }
    Process {

        try {           

            #typedef enum  { 
            $ADS_UF_SCRIPT = 1
            $ADS_UF_ACCOUNTDISABLE = 2
            $ADS_UF_HOMEDIR_REQUIRED = 8
            $ADS_UF_LOCKOUT = 16
            $ADS_UF_PASSWD_NOTREQD = 32
            $ADS_UF_PASSWD_CANT_CHANGE = 64
            $ADS_UF_ENCRYPTED_TEXT_PASSWORD_ALLOWED = 128
            $ADS_UF_TEMP_DUPLICATE_ACCOUNT = 256
            $ADS_UF_NORMAL_ACCOUNT = 512
            $ADS_UF_INTERDOMAIN_TRUST_ACCOUNT = 2048
            $ADS_UF_WORKSTATION_TRUST_ACCOUNT = 4096
            $ADS_UF_SERVER_TRUST_ACCOUNT = 8192
            $ADS_UF_DONT_EXPIRE_PASSWD = 65536
            $ADS_UF_MNS_LOGON_ACCOUNT = 131072
            $ADS_UF_SMARTCARD_REQUIRED = 262144
            $ADS_UF_TRUSTED_FOR_DELEGATION = 524288
            $ADS_UF_NOT_DELEGATED = 1048576
            $ADS_UF_USE_DES_KEY_ONLY = 2097152
            $ADS_UF_DONT_REQUIRE_PREAUTH = 4194304
            $ADS_UF_PASSWORD_EXPIRED = 8388608
            $ADS_UF_TRUSTED_TO_AUTHENTICATE_FOR_DELEGATION = 16777216
            #} ADS_USER_FLAG_ENUM;

            $computer = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer"

            $user = $computer.Create("User", $userName)
            $user.SetPassword($password.ToString())
            $user.SetInfo()
            $user.FullName = $fullName
            $user.SetInfo()
            $user.Description = "Perficient"
            $user.SetInfo()
            $user.UserFlags = $ADS_UF_DONT_EXPIRE_PASSWD
            $user.SetInfo()

            $group = $computer.psbase.children.find($groupName)
            $group.psbase.Invoke("Add",$user.psbase.path.tostring())
        }
        catch {          
                
            Show-Exception $_.Exception         
            Show-Usage                   
        }        
    }
}