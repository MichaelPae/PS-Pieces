function Read-Credential {
# liest ein verschluesseltes Password und erzeugt damit ein $PSCredential
	param( [String]$Username, [String]$CryptFqn )

	$Securestring = Get-Content $CryptFqn | ConvertTo-Securestring
	return New-Object -Typename System.Management.Automation.PSCredential -Argumentlist $Username, $Securestring
}
