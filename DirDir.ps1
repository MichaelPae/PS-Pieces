# Workaround fuer CMD-Befehl: DIR *.
Get-ChildItem | Where-Object {$_.attributes -eq "Directory"}