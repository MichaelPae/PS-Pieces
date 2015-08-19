# PowerShell Beispiel Script
# "#"         Inline Kommentar
# <#  ...  #> Blockkommentar
# `           Code-Zeilen-Umbruch
# ;              Befehle in einer Zeile trennen
# (...)       Runde Klammern haben algebraische Bedeutung:
#             Sie teilen der Shell mit, was zuerst ausgeführt wird.
# $           Variablen-Kennzeichen
[String]$HalloWelt = "Hallo Welt"     # Typisierung ist nicht zwingend
Write-Host ""; Write-Host $HalloWelt  # in der ISE sind die Var. nach Ausf. <F5> noch da
Write-Host "mit         ", ("Powershell-Version"+" " + $PSVersionTable.psversion)
Write-Host "auf PC      ", (Get-Content Env:Computername)
Write-Host "mit CPU-Typ ", (`
 Get-ItemProperty -path `
 "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"`
 ).PROCESSOR_ARCHITECTURE
<#
	Write-Host "mit CPU-Typ ", (Get-Content Env:Processor_Architecture)
#>
Write-Host "von User    ", (Get-Content Env:Username)
