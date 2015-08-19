# Beispiel fuer die Automation von Remote-PSSessions
param([Parameter(Mandatory=$true)][String]$CryptFqn)


function Write-Securestring {
	param([Securestring]$Securestring, [String]$CryptFqn)
	convertfrom-securestring -SecureString $Securestring | out-file $CryptFqn
}


function Read-Credential {
    param( [String]$Username, [String]$CryptFqn )
    $Securestring = get-content $CryptFqn | convertto-securestring
    return new-object -typename System.Management.Automation.PSCredential -argumentlist $Username, $Securestring
}


# Main
$ComputerName = "IE11WIN7"
$User = "IEUser"
$CryptFqn = "E:\PsTmp\IE11WIN7.TXT"

if (-not(Test-Path -Path $CryptFqn)) {
    # Enter-Securestring
    $Securestring = read-host -assecurestring 
    Write-Securestring -Securestring $Securestring -CryptFqn $CryptFqn
    Write-Host ("SecureString in "+ $CryptFqn +" abgelegt.")
    Get-ChildItem -Path $CryptFqn
}
$Cred = Read-Credential -Username $User -CryptFqn $CryptFqn

Enter-PSSession -ComputerName $ComputerName -Credential $Cred