# String (z.B. Password) verschluesselt auf die Platte legen. Z.B. fuer Automation von Remote-PSSession
param([Parameter(Mandatory=$true)][String]$CryptFqn)


function Write-Securestring {
	param([Securestring]$Securestring, [String]$CryptFqn)
	
	convertfrom-securestring -SecureString $Securestring | out-file $CryptFqn
}


# Startpunkt
# Enter-Securestring
$Securestring = read-host -assecurestring 
Write-Securestring -Securestring $Securestring -CryptFqn $CryptFqn
Write-Host ("SecureString in "+ $CryptFqn +" abgelegt.")
Get-ChildItem -Path $CryptFqn
