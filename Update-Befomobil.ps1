<#
.SYNOPSIS
	Aktualisiert eine BEFOmobil-Installation.
.DESCRIPTION
    Mit dem PS-Script Update-Befomobil wird eine BEFOmobil-Installation
    aktualisiert. Das Protokoll der installiereten Files wird als XML-Log
    unter <Befo2RootDir>Data\Log\befomobil.xml abgelegt.
.PARAMETER InstallDir
	Pfad zum Verzeichnis mit den Installations-Referenzverzeichnissen der
    BEFOmobil Processor-Varianten "X86" und "ARM".
.EXAMPLE
	Update-Befomobil.ps1
.NOTES
    1. Die Powershell Script-Verarbeitung muss auf dem Rechner freigeschaltet sein:
       Das benötigt den Registry-Wert unter
       HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell
           ExecutionPolicy = "RemoteSigned"
           "RemoteSigned" erfordert, dass alle aus dem Internet heruntergeladenen 
           Skripte und Konfigurationsdateien von einem vertrauenswürdigen Herausgeber
           signiert sind. Eigene Scripte werden sofort ausgefuehrt.
       Cmdlet in Administrator-Powershell: 
           Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    2. Eine Erstinstallation von BEFOmobil muss bereits erfolgt sein.
       Das Script setzt voraus, dass gemaess BEFOmobil-Installationsbeschreibung
       - Gruppenrichtlinie vertrauenswürdiger Apps (Apps.reg)
       - ein Sideloading-Produktschlüssel
       installiert sind.
    3. Das Powershell-Script sorgt selbst fuer den notwendigen Admin-Modus. 
       Admin-Modus wird fuer Cmdlet "Import-Certificate" benoetigt.
.LINK 
#>

param([string]$InstallDir)


function Get-IsAdmin {
# ermittelt Admin-Modus
    [Bool]$Admin = $true
    Try {
    # Wenn Set-ExecutionPolicy fehlschlaegt, fehlen die Adminrechte
    Get-ExecutionPolicy | Set-ExecutionPolicy -ErrorAction Stop 
    } Catch {
        $Admin = $false
    }
    return $Admin
}


function Get-ScriptRunTimeDir{
# ermittelt das Laufzeitverzeichnis des Scripts
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
}


function Get-BefomobilExeType {
# ermittelt BefomobilExeType aus Processor_Architecture
#    Amd64	A 64-bit AMD processor only.
#    Arm	An ARM processor.
#    IA64	A 64-bit Intel processor only.
#    MSIL	Neutral with respect to processor and bits-per-word.
#    None	An unknown or unspecified combination of processor and bits-per-word.
#    X86	A 32-bit Intel processor, either native or in the Windows on Windows environment on a 64-bit platform (WOW64).
    $ProcArch = get-ChildItem env:processor_architecture -ErrorAction SilentlyContinue
    if (-not$ProcArch) {
        $ProcType = "X86" # Default-Type
    } elseif ($ProcArch.Value.ToUpper() -eq "ARM") {
        $ProcType = "ARM"
    } else {
        $ProcType = "X86"
    }
    return $ProcType
}


function Get-BefoIIRegKey {
<#
.SYNOPSIS
	Holt Werte der BEFO II-Registry-Eintraege.
.DESCRIPTION
    Mit der Function Get-BefoIIRegKey werden Werte der BEFO II-Registry-Eintraege geholt.
.PARAMETER Key
	BEFO II-Registry-Schluessel.
.PARAMETER Name
	Property-Name eines BEFO II-Registry-Schluessels.
.PARAMETER Default
	Defaultwert, falls die Property nicht angelegt ist.
.EXAMPLE
	Get-BefoIIRegKey
.NOTES

.LINK 
	http://www.befo.com
#>
    param([Parameter(Mandatory=$true)][String]$Key, [Parameter(Mandatory=$true)][String]$Name, [String]$Default="C:\BEFO2\")

    $InstallKeyProp = Get-ItemProperty -path ("HKLM:\SOFTWARE\BEFO II\"+$Key) -name $Name -ErrorAction SilentlyContinue
    if (-not$InstallKeyProp) {
        $InstallKeyProp = Get-ItemProperty -path ("HKLM:\SOFTWARE\Wow6432Node\BEFO II\"+$Key) -name $Name -ErrorAction SilentlyContinue
    }

    if ($InstallKeyProp) {
        $BefoRoot = $InstallKeyProp.Verzeichnis    
    } else {
        $BefoRoot = $Default    
    }
    return $BefoRoot    
}


function New-SubDir {
    param([Parameter(Mandatory=$true)][String]$RootDir, [Parameter(Mandatory=$true)][String]$SubDir)
    if (-not(Test-Path -Path ($RootDir+$SubDir)))  {
        New-Item -Path $RootDir -Name $SubDir -ItemType directory | Out-Null
    }
}


# Main
$Default = "E:\BENUTZER\Öffentlich\Projekte\INETA DevGroup GoettingenKassel\2015-09-17_PowerShell\BEFOmobil" # "\\abel\befo_p\BEFO2\DTM\RUN\bMobile\BEFOmobil\BEFOmobil" #
$Path = Get-ScriptRunTimeDir
$ParmFile = ($Path+"\"+"InstallDir.txt")

# Parameter $InstallDir sicherstellen
if (-not($InstallDir) -and (Get-IsAdmin)) {
# Lauf-Nr. unklar
    if (Test-Path -Path $ParmFile) {
    # 2. Lauf
        $InstallDir = Get-Content -Path $ParmFile      
    } else {
    # 1. Lauf
        $InstallDir = $Default
    }  
     
} else {
# 1. Lauf
    if (-not($InstallDir)) {
        $InstallDir = $Default
    } 
    $InstallDir | Set-Content -Path $ParmFile
}


# fuer Admin-Rechte sorgen
if (-not(Get-IsAdmin)) {
    Write-Host "Neustart im Admin-Modus ..."
    $args = "& '" + $myinvocation.mycommand.definition +"'"
    # PowerShell im Admin-Modus starten
    Start-Process powershell -Verb runAs -ArgumentList $args
    Break
}


# ab hier ist Admin-Modus ist gewaehrleistet

# $ParmFile loeschen (temp. serialisierte Aufrufparameter)
Remove-Item -Path $ParmFile -ErrorAction SilentlyContinue
 
# InstallDir vervollstaendigen (ExeType ermitteln)
$ExeType = Get-BefomobilExeType
$InstallDir = ($InstallDir+"\"+ $ExeType)

# neue File-Metadaten holen
$Update = Get-Item -Path ($InstallDir+"\*") -Include "befomobil.*" -Exclude "*.xml" | Sort-Object Name

# Meldung Referenz-Files
if (-not($Update) -or (($Update) -and ($Update.Length -eq 0)) ) {
    Write-Output ("Keine Referenz-Files in "+$InstallDir+" gefunden.")
    Start-Sleep -Seconds 5
    break

} else {
    Write-Output ("Anzahl Referenz-Files in "+$InstallDir+" : "+$Update.Length.ToString())
}

# BEFO II Standort ermitteln
$BefoRoot = Get-BefoIIRegKey -Key Install -Name Verzeichnis -Default "C:\BEFO2\"
$BefoLw = $BefoRoot.Split("\")[0]+"\"
$BefoRootDir = $BefoRoot.Substring(3, $BefoRoot.Length-3) 
$LogSubDir = "Data\Log"

# fuer BEFO II Log-Verzeichnis sorgen
New-SubDir -RootDir $BefoLw -SubDir $BefoRootDir
New-SubDir -RootDir ($BefoLw+$BefoRootDir) -SubDir $LogSubDir

# alte File-Metadaten aus letztem UpdateLog deserialisieren
$UpdateLog = $BefoLw+$BefoRootDir+$LogSubDir+"\befomobil.xml"
if (Test-Path -Path $UpdateLog) {
    $LastUpdate = Import-Clixml -Path $UpdateLog
}

# Update-Kriterium
if (!$LastUpdate) {
    $RunUpdate = $True
} else {
    $Diff = Compare-Object -ReferenceObject $Update -DifferenceObject $LastUpdate -property LastWriteTime, Length, Name -PassThru | Where-Object { $_.SideIndicator -eq '=>' }
    $RunUpdate = ($Diff.Length -gt 0)
}
if (-not($RunUpdate)) {
    Write-Output "Kein Update notwendig."
    Start-Sleep -Seconds 2
    break
}

# Process BEFO.BEFOmobil stoppen
Write-Output "Stop-Process BEFO.BEFOmobil ..."
$Running = Get-Process -name BEFO.BEFOmobil* # Process BEFO.BEFOmobil.DataSync nicht beenden
$Running | foreach-object { 
    if ($_.ProcessName -ne "") {Stop-Process -name $_.ProcessName} ##{Write-Output $_.ProcessName }
}

# ins Installations-Verzeichnis wechseln
$Origin = Get-Location
Set-Location -Path $InstallDir

# Certificat installieren
Write-Output "Import BEFO-Zertifikat ..."
Import-Certificate -Filepath .\BEFOmobil.cer -CertStoreLocation cert:\LocalMachine\AuthRoot

# altes AppxLog loeschen
$AppxLog = $BefoLw+$BefoRootDir+$LogSubDir+"\appx.xml"
remove-item -Path $AppxLog -ErrorAction SilentlyContinue

# App-Install Modul laden
Write-Output ("BEFOmobil aus "+$InstallDir+" aktualisieren ...")
Import-Module appx

# neue BEFOmobil Version installieren
Try {
    $AppxRes = Add-AppxPackage BEFOmobil.appx -ErrorAction Stop -ErrorVariable $AppxError 

} Catch {
    # Error als Protokoll bereitstellen
    $AppxRes = $AppxError
}

# Appx Log serialisieren
$AppxRes | Export-Clixml -Path $AppxLog

# Location restaurieren
Set-Location -Path $Origin

# Abschlussmeldung
$Duration = 1
if ((get-content -Path $AppxLog | Measure-Object -Line).Lines -eq 1) {
    $Update | Export-Clixml -Path $UpdateLog
    Write-Output "Update ist erfolgt."
} else {
    Write-Host "KEIN Update: Add-AppxPackage-Problem " -BackgroundColor "Red" -ForegroundColor "Black"
    $Duration = 5
}
Start-Sleep -Seconds $Duration
