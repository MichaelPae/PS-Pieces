# PowerShell Beispiel Script
# "#"            Inline Kommentar
# <# ... #>      Blockkommentar
# `              Code-Zeilen-Umbruch mit dem „Gravis“-Zeichen
# ;              Befehle in einer Zeile trennen
# (...)          Runde Klammern haben algebraische Bedeutung:
#                Sie teilen der Shell mit, was zuerst ausgeführt wird.
# {...}          Geschweifte Klammern schließen Codeblöcke ein
# $              Variablen-Kennzeichen
# $true, $false  Boolsche Konstanten als Pseudo-Variablen
#
# Autor: Michael Pätzold

[String]$HalloWelt = "Hallo Welt"     # Typisierung ist nicht zwingend
Write-Host ""; Write-Host $HalloWelt  # in der ISE sind die Var. nach Ausf. <F5> noch da
Write-Host "mit         ", ("Powershell-Version"+" " + $PSVersionTable.psversion).ToString()
Write-Host "auf PC      ", (Get-Content Env:Computername)
Write-Host "mit CPU-Typ ", (`
 Get-ItemProperty -path `
 "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"`
 ).PROCESSOR_ARCHITECTURE
<#
    # alternativer Code-Vorschlag
    Write-Host "mit CPU-Typ ", (Get-Content Env:Processor_Architecture)
#>

if (-not$false) { # Bool-Operatoren  -not ! -eq, -nq, ...
    Write-Host "von User    ", (Get-Content Env:Username)
} else {
    "Diese Stelle wird nie erreicht"    
}
