# PowerShell Beispiel Script fuer eine Log-Datei
#
# Autor: Michael Pätzold

# Log-File-Name
$xLog = "Mein.log" # der Var.-Name "xLog" steht am Ende der Liste > GCI variable:

# Log-File anlegen
New-Item -Path . -Name $xLog -Type "file" –Value "1. Zeile`r`n" -Force

# Log-File fortschreiben
"nächste Zeile" | Add-Content -Path $xLog

# Log-File ausgeben
Write-Host ""; Write-Host "--- Ausgabe folgt ---" 
Get-Content -Path $xLog
