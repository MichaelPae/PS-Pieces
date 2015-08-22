# String verschluesselt auf die Platte legen.
#    Z.B. fuer die Erzeugung einer Credential-Variable
#
# Autor: Michael Pätzold

param([Parameter(Mandatory=$true)][String]$CryptFqn)

# Kennwort erfassen
$Securestring = read-host -assecurestring 

# Securestring erzeugen
convertfrom-securestring -SecureString $Securestring | out-file $CryptFqn

# Ergebnis anzeigen
Write-Host ("SecureString in "+ $CryptFqn +" abgelegt.")
Get-ChildItem -Path $CryptFqn
