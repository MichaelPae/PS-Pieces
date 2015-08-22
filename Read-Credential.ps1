function Read-Credential {
# liest ein verschluesseltes Password und erzeugt damit ein $PSCredential
#
# Autor: Michael Pätzold

	param( [String]$Username, [String]$CryptFqn )

	$Securestring = Get-Content $CryptFqn | ConvertTo-Securestring
	return New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $Username, $Securestring
}

# Starting Point
# Test Read-Credential
$Cred = Read-Credential -Username IEUser -CryptFqn .\IE11WIN7.TXT
$Cred
