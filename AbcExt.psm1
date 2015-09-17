<#
.SYNOPSIS
	This Powershell module provides Abc Extensions.
.DESCRIPTION
	This Powershell module provides Abc Extensions.
.PARAMETER Parm1
	...
.PARAMETER Parm2
	...
.EXAMPLE
	Import-Module AbcExt.psm1
.NOTES
    Author: Michael Pätzold
.LINK 
	http://www.michael-paetzold.de
#>
[long]$script:test=0 # initialize Variable


function Get-IsAdmin {
<#
.SYNOPSIS
	Ermittelt Admin-Modus.
.DESCRIPTION
    Mit der Function Get-IsAdmin wird ermittelt, ob das Script im Admin-Modus laeuft.
    Rueckgabe: $true    Script hat Admin-Modus
               $false   Script hat kein Admin-Modus
.EXAMPLE
	Get-IsAdmin
.NOTES
    Autor: Michael Pätzold
.LINK 
#>
    [Bool]$Admin = $true
    Try {
    # Wenn Set-ExecutionPolicy fehlschlaegt, fehlen die Adminrechte
    Get-ExecutionPolicy | Set-ExecutionPolicy -ErrorAction Stop 
    } Catch {
        $Admin = $false
    }
    return $Admin
}


function Read-Credential {
<#
.SYNOPSIS
    Liest ein Kennwort aus verschluesselter Datei und erzeugt daraus ein Credential-Object.
.DESCRIPTION
    Mit dem Cmdlet Read-Credential wird ein Kennwort aus einer verschluesselten Datei gelesen.
    Zusammen mit einem User-Namen wird ein Credential-Object erzeugt.
.PARAMETER Username
    Username fuer das Credential-Object
.PARAMETER PasswordFqn
    Full-Qualified-Filename des Files mit dem verschluesselten Kennwort
.EXAMPLE
	Read-Credential -Username $Username -PasswordFqn $PasswordFqn
.NOTES
    Autor: Michael Pätzold
.LINK 
#>
param( [String]$Username, [String]$PasswordFqn )
    $password = get-content $PasswordFqn | convertto-securestring
    return new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$password
}


function Set-PSWinTitle {
<#
.SYNOPSIS
	Setzt den Titel des aktuellen Powershell Windows.
.DESCRIPTION
    Mit dem Cmdlet Set-PSWinTitle wird der Titel des aktuellen Powershell Windows neu gesetzt.
.PARAMETER NewTitle
	neuer Powershell Windows Titel
.EXAMPLE
	set-PSWinTitle -NewTitle "Ineta PS-Session"
.NOTES
    Autor: Michael Pätzold
.LINK 
#>
param ( [string] $NewTitle = "Ineta PS-Session")

    Process{
        $host.ui.RawUI.WindowTitle = $NewTitle # + " - " + $host.ui.RawUI.WindowTitle;
    }
}


# Laden des Moduls angezeigen
write-host "Abc-Extensions sind geladen."
write-host ""

# New-ModuleManifest -path .\AbcExt.psd1 -CompanyName "Ineta DevGroup GöKs" -Copyright '(c) 2015 Michael Pätzold. Alle Rechte vorbehalten.'
