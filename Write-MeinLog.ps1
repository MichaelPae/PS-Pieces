# PowerShell Beispiel Script fuer eine Log-Datei

$xLog = "Mein.log" 

# Log-File anlegen
New-Item -Path . -Name $xLog -Type "file" –Value "1. Zeile`r`n" -Force

# File fortschreiben
"nächste Zeile" | Add-Content -Path $xLog

# Ausgabe des Log-Files
Write-Host ""; Write-Host "--- Ausgabe folgt ---" 
Get-Content -Path $xLog
