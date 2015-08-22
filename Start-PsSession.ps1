<#
.SYNOPSIS
    Startet eine PowerShell Remote-Session
.DESCRIPTION
    Mit dem Script Start-PsSession.ps1 wird eine PowerShell Remote-Session
    gestartet. Falls der Securestring serialisiert auf der Platte vorliegt,
    ohne weiteren Dialog.
.PARAMETER CryptFqn
	Filename des verschluesselten Kennworts 
.EXAMPLE
	.\Start-PsSession -CryptFqn IE11WIN7.TXT
.NOTES
    Beispiel fuer die Automation von Remote-PSSessions

    Autor: Michael Pätzold    
.LINK
#>

param([Parameter(Mandatory=$true)][String]$CryptFqn)


function Write-Securestring {
# schreibt ein verschluesseltes Password in eine Datei.
#
# Autor: Michael Pätzold

	param([Securestring]$Securestring, [String]$CryptFqn)
	ConvertFrom-SecureString -SecureString $Securestring | Out-File $CryptFqn
}


function Read-Credential {
# liest ein verschluesseltes Password und erzeugt damit ein $PSCredential.
#
# Autor: Michael Pätzold

	param( [String]$Username, [String]$CryptFqn )

	$Securestring = Get-Content $CryptFqn | ConvertTo-Securestring
	return New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $Username, $Securestring
}


# Starting Point
$ComputerName = "IE11WIN7"
$User = "IEUser"
$CryptFqn = "E:\PsTmp\IE11WIN7.TXT"

if (-not(Test-Path -Path $CryptFqn)) {
    # Kennwort erfassen
    $Securestring = read-host -assecurestring 
    Write-Securestring -Securestring $Securestring -CryptFqn $CryptFqn
    Write-Host ("SecureString in "+ $CryptFqn +" abgelegt.")
    Get-ChildItem -Path $CryptFqn
}

# Variable mit Anmeldedaten
$Cred = Read-Credential -Username $User -CryptFqn $CryptFqn

# Remote Session starten
Enter-PSSession -ComputerName $ComputerName -Credential $Cred