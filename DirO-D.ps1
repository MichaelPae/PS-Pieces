# Workaround fuer CMD-Befehl: DIR *.* /o-d
param([Parameter(Mandatory=$true)][String]$Pattern, [Int]$Anzahl=10)

Get-ChildItem $Pattern | 
 Sort-Object LastWriteTime -Desc | 
 Select-Object -first $Anzahl
