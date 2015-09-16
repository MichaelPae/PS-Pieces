<#
.SYNOPSIS
    Xbase++ Project Builder (compilieren und linken)
    erzeugt ein Xbase++ Build.
.DESCRIPTION
    Mit dem Cmdlet Build-Xpp wird ein Xbase++ Build erzeugt. Falls
    ein Prozess mit dem Namen des Script-Parameters 'XpjBaseName'
    aktiv ist, wird dieser Prozess beendet. Falls des BaseName
    der erzeugten Exe gleich dem Namen des Script-Parameters
    'XpjBaseName' ist, wird diese Exe entsprechen dem Script-
    Parameter 'Testen' gestartet.
.PARAMETER XpjBaseName
    Basename des Xbase-Projekt-Files .XPJ
.PARAMETER Testen
    Kommando zum Start der neu erzeugten Xbase-EXE
    N :    neue Exe Nicht ausführen
    D :    neue Exe mit Debug-Code erzeugen und im Debug-Modus starten
.EXAMPLE
    Build-Xpp -XpjBaseName "XppApp" -Testen "N"
.NOTES
    Die Projekt-Datei .XPJ wird bei jedem Aufruf aktualisiert.

    Autor: Michael Pätzold
.LINK 
#>
param([Parameter(Mandatory=$true)][String]$XpjBaseName, [String]$Testen="J")


function Build-Xpp {
param([Parameter(Mandatory=$true)][String]$XpjBaseName, `
      [String]$Testen="J", `
      [String]$Location=(Get-Location).Drive.CurrentLocation)
$FqnXpj = $Location+"\"+$XpjBaseName+".XPJ"
$FqnExe = $Location+"\"+$XpjBaseName+".EXE"
$Debug = $False
Write-Host ""

if ($Testen.ToUpper() -eq "D") {
    $Debug = $True
    Write-Host "Debug-Session!"
}

# Object-Code-Directory checken
if (-not(Test-Path -Path $XpjBaseName))  {
   New-Item -Path (Get-Location).path -Name $XpjBaseName -ItemType directory
}

# Project reset
Stop-XppProcess -Process $XpjBaseName
Remove-Item -path $XpjBaseName".EXE" -ErrorAction SilentlyContinue
attrib ($XpjBaseName+".xpj") -r
Start-Process -FilePath pbuild -ArgumentList ($XpjBaseName+".xpj /g") -NoNewWindow -Wait

# Build Parameter zusammenstellen
if ($Debug) {
   $ArgPbuild = $XpjBaseName+".xpj /a /dDEBUG=YES"
} else {
   $ArgPbuild = $XpjBaseName+".xpj /a"
}

# Build erzeugen
Start-Process -FilePath pbuild -ArgumentList $ArgPbuild -NoNewWindow -Wait

# Build-Existenz Pruefen
$Success = Test-Path -Path $XpjBaseName".EXE"

# neues Build gleich starten
if ($Success -and ($Testen.ToUpper() -ne "N")) {
    if ($Debug) {
        Start-Process -FilePath "XPPDBG.EXE" -ArgumentList ($XpjBaseName+".EXE")
    } else {
        Start-Process -FilePath ($XpjBaseName+".EXE")
    }
}

return $Success
}


function Stop-XppProcess {
	# stoppt Process $Process
	param([Parameter(Mandatory=$true)][String]$Process)

	if ($Process.ToUpper() -ne "START") {
		Stop-Process -Name $Process -ErrorAction SilentlyContinue
	}
}

# Hier geht's erst looooooooos ...
$Script = $myInvocation.MyCommand.Name
$Log = "Build-Xpp.log"

# Build-Protokoll starten
new-item -path . -name $Log -type "file" -value ("Start "+ $Script +" "+(Get-Date).ToString()+"`r`n") -force | Out-Null

# Build durchführen
$Success = Build-Xpp -XpjBaseName $XpjBaseName -Testen $Testen

# Build-Protokoll fortschreiben
$LogLine = $XpjBaseName.ToUpper()+".EXE"+" Build"
if ($Success){
    $LogLine = $LogLine+" Build erfolgreich!"
    $BgrCol = "DarkGreen"
    $FgrCol = "White"
} else {
    $LogLine = $LogLine+" Build NICHT erfolgreich!"
    $BgrCol = "Black"
    $FgrCol = "Red"
}
$LogLine | Add-Content $Log
("Ende " +$Script +" "+(Get-Date).ToString()+"`r`n") | Add-Content $Log
Get-Content -Path $Log | Write-Host -BackgroundColor $BgrCol -ForegroundColor $FgrCol
